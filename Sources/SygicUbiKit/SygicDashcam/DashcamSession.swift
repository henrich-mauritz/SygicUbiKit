import AVFoundation
import CoreGraphics
import MetalKit
import UIKit

// MARK: - DashcamSession

open class DashcamSession: NSObject {
    // MARK: Public

    public private(set) var recording = false {
        willSet {
            DispatchQueue.main.async {
                UIApplication.shared.isIdleTimerDisabled = newValue
                self.recordingClosure?(newValue)
                self.provider.dashcamRecording(newValue)
            }
        }
    }

    public private(set) var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: Internal

    var exportingClosure: ((_ exporting: Bool) -> Void)?
    var recordingClosure: ((_ recording: Bool) -> Void)?

    private(set) var exporting = false {
        willSet {
            exportingClosure?(newValue)
        }
    }

    var recordAudio: Bool {
        UserDefaults.dashcamSoundEnabled
    }

    private(set) var recordingOrientation: AVCaptureVideoOrientation = .portrait

    // MARK: Private

    private let crashDetector = DashcamCrashDetector()
    private let videoPartLength: TimeInterval = 60.0
    // Communicate with the session and other session objects on this queue.
    private let sessionQueue = DispatchQueue(label: "com.sygic.dashcam.processing")
    private let imageProcessingQueue = DispatchQueue(label: "com.sygic.dashcam.imageProcessing")
    private let semaphore = DispatchSemaphore(value: 2)
    private let directoryPath = NSTemporaryDirectory()
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let audioOutput = AVCaptureAudioDataOutput()
    private let dashcamFileMark = "-dashcam-"

    private var captureDevice: AVCaptureDevice?
    private var adaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var videoWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?
    private var audioWriterInput: AVAssetWriterInput?
    private var timeCode = CMTime.zero
    private var loopCount: Int = 0
    private var tempLocation = ""
    private var audioInputStored: AVCaptureDeviceInput?
    private var recordingInterupted = false
    private var maxTotalDashcamSessionDurationInMinutes: Int { UserDefaults.dashcamVideoDuration }

    private var autostartShouldRecordFirstSessionFlag = true

    private var quality: VideoQuality {
        VideoQuality(rawValue: UserDefaults.dashcamVideoQuality) ?? .SD
    }

    private var duration: VideoDuration {
        VideoDuration(rawValue: UserDefaults.dashcamVideoDuration) ?? .min1
    }

    private var locationUpdateTimer: Timer? {
        willSet {
            locationUpdateTimer?.invalidate()
        }
    }

    private var loopTimer: Timer? {
        willSet {
            loopTimer?.invalidate()
        }
    }

    private var audioInput: AVCaptureDeviceInput? {
        guard recordAudio else { return nil }

        if let audioInicialized = audioInputStored {
            return audioInicialized
        } else if let audio = AVCaptureDevice.default(for: .audio) {
            audioInputStored = try? AVCaptureDeviceInput(device: audio)
            return audioInputStored
        }

        return nil
    }

    private lazy var backCamera: AVCaptureDevice? = {
        guard let camera = AVCaptureDevice.default(for: .video) else { return nil }
        if camera.isFocusModeSupported(.locked) {
            do {
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
                camera.unlockForConfiguration()
            } catch {
                print("Error locking camera configuration")
            }
        }
        return camera
    }()

    private lazy var videoInput: AVCaptureDeviceInput? = {
        guard let backCamera = self.backCamera else { return nil }
        return try? AVCaptureDeviceInput(device: backCamera)
    }()

    private lazy var metalDevice: MTLDevice? = {
        MTLCreateSystemDefaultDevice()
    }()

    private lazy var ciContext: CIContext? = {
        guard let metalDevice = metalDevice else { return nil }
        return CIContext(mtlDevice: metalDevice)
    }()

    public let provider: DashcamProviderProtocol

    public init(provider: DashcamProviderProtocol) {
        self.provider = provider
        super.init()
        recordingOrientation = DashcamHelpers.currentOrientationForAVCapture()
        crashDetector.crashDetected = { [weak self] in
            self?.stopRecording()
        }
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate

extension DashcamSession: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    open func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let videoWriter = videoWriter, recording else { return }
        if output == audioOutput && videoWriter.status == .unknown {
            return
        }
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = recordingOrientation
        }
        if videoWriter.status == .unknown {
            if videoWriter.startWriting() {
                timeCode = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                videoWriter.startSession(atSourceTime: timeCode)
            } else { return }
        }
        semaphore.wait()
        imageProcessingQueue.async { [weak self] in
            self?.processCapturedOutput(sampleBuffer, output, videoWriter)
            self?.semaphore.signal()
        }
    }
}

// MARK: - Private

private extension DashcamSession {
    // MARK: Overlays

    func processCapturedOutput(_ sampleBuffer: CMSampleBuffer!, _ captureOutput: AVCaptureOutput!, _ videoWriter: AVAssetWriter) {
        guard videoWriter.status == .writing else { return }
        timeCode = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        if captureOutput == videoOutput {
            processVideoOutput(from: sampleBuffer)
        } else if captureOutput == audioOutput {
            processAudioOutput(from: sampleBuffer, to: videoWriter)
        }
    }

    func processAudioOutput(from sampleBuffer: CMSampleBuffer, to videoWriter: AVAssetWriter) {
        guard let audioWriterInput = audioWriterInput,
              videoWriter.inputs.contains(audioWriterInput),
              audioWriterInput.isReadyForMoreMediaData else { return }
        if recordAudio {
            audioWriterInput.append(sampleBuffer)
        } else if let silentBuffer = createSilentAudio(startFrm: 0, nFrames: 1, sampleRate: 44100.0, numChannels: 1) {
            audioWriterInput.append(silentBuffer)
        }
    }

    func processVideoOutput(from sampleBuffer: CMSampleBuffer) {
        guard captureSession.isRunning else { return }
        guard let adaptor = adaptor, adaptor.assetWriterInput.isReadyForMoreMediaData else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        if UserDefaults.dashcamShouldShowOverlay {
            guard let writerInput = videoWriterInput, writerInput.isReadyForMoreMediaData else { return }
            let cameraImage = CIImage(cvImageBuffer: pixelBuffer)
            guard let overlayImage = overlayImage().ciImage else { return }
            if let outputImage = combineImages(background: cameraImage, overlay: overlayImage) {
                ciContext?.render(outputImage, to: pixelBuffer, bounds: outputImage.extent, colorSpace: nil)
            }
            adaptor.append(pixelBuffer, withPresentationTime: timeCode)
        } else {
            adaptor.append(pixelBuffer, withPresentationTime: timeCode)
        }
    }

    func combineImages(background bgImage: CIImage, overlay overlayImage: CIImage) -> CIImage? {
        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        combinedFilter.setValue(overlayImage, forKey: "inputImage")
        combinedFilter.setValue(bgImage, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage
    }

    func createSilentAudio(startFrm: Int64, nFrames: Int, sampleRate: Float64, numChannels: UInt32) -> CMSampleBuffer? {
        let bytesPerFrame = UInt32(2 * numChannels)
        let blockSize = nFrames * Int(bytesPerFrame)

        var block: CMBlockBuffer?
        var status = CMBlockBufferCreateWithMemoryBlock(
            allocator: kCFAllocatorDefault,
            memoryBlock: nil,
            blockLength: blockSize,
            blockAllocator: nil,
            customBlockSource: nil,
            offsetToData: 0,
            dataLength: blockSize,
            flags: 0,
            blockBufferOut: &block
        )
        assert(status == kCMBlockBufferNoErr)

        // We seem to get zeros from the above, but I can't find it documented. so... memset:
        guard let blockBuffer = block else { return nil }
        status = CMBlockBufferFillDataBytes(with: 0, blockBuffer: blockBuffer, offsetIntoDestination: 0, dataLength: blockSize)
        assert(status == kCMBlockBufferNoErr)

        var asbd = AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kLinearPCMFormatFlagIsSignedInteger,
            mBytesPerPacket: bytesPerFrame,
            mFramesPerPacket: 1,
            mBytesPerFrame: bytesPerFrame,
            mChannelsPerFrame: numChannels,
            mBitsPerChannel: 16,
            mReserved: 0
        )

        var formatDesc: CMAudioFormatDescription?
        status = CMAudioFormatDescriptionCreate(allocator: kCFAllocatorDefault, asbd: &asbd, layoutSize: 0, layout: nil, magicCookieSize: 0, magicCookie: nil, extensions: nil, formatDescriptionOut: &formatDesc)
        assert(status == noErr)

        guard let formatDescription = formatDesc else { return nil }

        var sampleBuffer: CMSampleBuffer?

        status = CMAudioSampleBufferCreateReadyWithPacketDescriptions(
            allocator: kCFAllocatorDefault,
            dataBuffer: blockBuffer,
            formatDescription: formatDescription,
            sampleCount: nFrames,
            presentationTimeStamp: CMTimeMake(value: startFrm, timescale: Int32(sampleRate)),
            packetDescriptions: nil,
            sampleBufferOut: &sampleBuffer
        )
        assert(status == noErr)

        return sampleBuffer
    }

    func setupUpdateLocationTimer() {
        locationUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLocationUI), userInfo: nil, repeats: true)
    }

    func overlayText() -> String {
        var text: String = self.currentDate()
        text = "\(text)\n\(tempLocation)"

        return text
    }

    func overlayImage() -> UIImage {
        overlayText().image(attributes: overlayFontAttributes(), rect: CGRect(x: 10, y: 0, width: 300, height: 25))
    }

    func currentDate() -> String {
        DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
    }

    func currentPosition() -> String? {
        let location = provider.data

        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 5
        formatter.maximumFractionDigits = 5

        let latitude = formatter.string(from: NSNumber(value: location.latitude)) ?? ""
        let longitude = formatter.string(from: NSNumber(value: location.longitude)) ?? ""
        let speedInUnits = Int(DashcamFormatter.format(location.speed ?? 0, from: .km, to: provider.distanceUnit))
        let speed = String(speedInUnits)

        return "Lat: \(latitude)  Long: \(longitude)  Speed: \(speed)\(provider.distanceUnit.speedTitle)"
    }

    func overlayFontAttributes() -> [NSAttributedString.Key: Any] {
        if let textFont = UIFont(name: "Helvetica Bold", size: 8) {
            let textColor = UIColor.white
            return [.font: textFont, .foregroundColor: textColor]
        }
        return [:]
    }

    // MARK: Recording

    func captureResolution() -> CGSize {
        guard let formatDescription = self.backCamera?.activeFormat.formatDescription else { return .zero }
        let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        let resolution = dimensions.resolution(for: recordingOrientation)
        return resolution
    }

    func adaptorProperties() -> [String: Any] {
        [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB)]
    }

    func videoProperties() -> [String: Any]? {
        let outputSize = captureResolution()
        guard outputSize != .zero else { return nil }
        let outputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: NSNumber(value: Float(outputSize.width)),
            AVVideoHeightKey: NSNumber(value: Float(outputSize.height)),
        ]
        return outputSettings
    }

    func audioProperties() -> [String: Any] {
        var acl: AudioChannelLayout?
        bzero(&acl, MemoryLayout.size(ofValue: acl))
        acl?.mChannelLayoutTag = kAudioChannelLayoutTag_Mono

        let audioOutputSettings: [String: Any] = [
            AVFormatIDKey: NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
            AVSampleRateKey: NSNumber(value: 44100.0),
            AVNumberOfChannelsKey: NSNumber(value: 1),
            AVChannelLayoutKey: NSData(bytes: &acl, length: MemoryLayout.size(ofValue: acl)),
        ]

        return audioOutputSettings
    }

    // MARK: Video

    func startRecordingPart() {
        guard let fileUrl = NSURL(fileURLWithPath: directoryPath).appendingPathComponent("\(UUID())\(dashcamFileMark)part\(loopCount).mp4") else { return }
        videoWriter = try? AVAssetWriter(outputURL: fileUrl, fileType: .mp4)
        if let videoProperties = videoProperties() {
            videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoProperties)
        }
        audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioProperties())

        guard let videoWriter = videoWriter, let videoWriterInput = videoWriterInput, let audioWriterInput = audioWriterInput else { return }

        videoWriterInput.expectsMediaDataInRealTime = true
        audioWriterInput.expectsMediaDataInRealTime = true
        videoWriter.add(videoWriterInput)
        videoWriter.add(audioWriterInput)

        adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: adaptorProperties())
    }

    func stopRecordingPart(_ completion: (() -> Void)? = nil) {
        guard recording, let videoWriter = videoWriter, let videoWriterInput = videoWriterInput, let audioWriterInput = audioWriterInput, videoWriter.status == .writing else {
            completion?()
            return
        }

        videoWriterInput.markAsFinished()

        if videoWriter.inputs.contains(audioWriterInput) {
            audioWriterInput.markAsFinished()
        }
        videoWriter.finishWriting {
            completion?()
        }
    }

    func configureSession() throws {
        guard let videoInput = videoInput else { throw DashcamError.noVideoInput }
        guard captureSession.isRunning == false else { return }

        captureSession.beginConfiguration()

        let sessionHasVideoInput = captureSession.inputs.contains(where: { input -> Bool in (input as? AVCaptureDeviceInput) == videoInput })
        if !sessionHasVideoInput {
            captureSession.addInput(videoInput)
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
            captureSession.addOutput(videoOutput)
        }

        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    func configureSessionForAudioRecording() throws {
        guard recordAudio else { return }
        guard let audioInput = audioInput else { throw DashcamError.noAudioInput }
        let sessionHasAudioInput = captureSession.inputs.contains(where: { input -> Bool in (input as? AVCaptureDeviceInput) == audioInput })
        if !sessionHasAudioInput && captureSession.canAddInput(audioInput) && captureSession.canAddOutput(audioOutput) {
            provider.setAudioSessionActive(true)
            captureSession.automaticallyConfiguresApplicationAudioSession = false
            captureSession.beginConfiguration()
            captureSession.addInput(audioInput)
            audioOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            captureSession.addOutput(audioOutput)
            captureSession.commitConfiguration()
        }
    }

    func configureSessionWithoutAudio() {
        guard let audioInput = audioInputStored else { return }
        let sessionHasAudioInput = captureSession.inputs.contains(where: { input -> Bool in (input as? AVCaptureDeviceInput) == audioInput })
        if sessionHasAudioInput {
            captureSession.beginConfiguration()
            captureSession.removeInput(audioInput)
            captureSession.removeOutput(audioOutput)
            captureSession.commitConfiguration()
        }
        if recordAudio {
            provider.setAudioSessionActive(false)
        }
        audioInputStored = nil
    }

    // MARK: Session Notifications

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: captureSession)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: captureSession)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: captureSession)
    }

    @objc
    func loopTimerSelector() {
        guard recordingInterupted == false else { return }

        loopCount += 1

        sessionQueue.async {
            self.stopRecordingPart {
                self.eraseOldVideoParts()
            }
            self.startRecordingPart()
        }
    }
}

extension DashcamSession {
    func getAVPreset(from videoQuality: VideoQuality) -> AVCaptureSession.Preset {
        switch videoQuality {
        case .HD: return AVCaptureSession.Preset.hd1920x1080
        case .SD: return AVCaptureSession.Preset.hd1280x720
        case .VGA: return AVCaptureSession.Preset.vga640x480
        }
    }

    func beginSession() throws {
        /*
         Setup the capture session.
         In general it is not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         */
        addObservers()
        try? self.configureSession()
    }

    func setupPreviewLayer(completion: @escaping ((_ layer: AVCaptureVideoPreviewLayer?) -> Void)) {
        /*
         Why not do all of this on the main queue?
         Because AVCaptureSession.startRunning() is a blocking call which can
         take a long time. We dispatch session setup to the sessionQueue so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        guard self.previewLayer == nil else {
            completion(nil)
            return
        }
        addObservers()
        sessionQueue.async { [weak self] in
            guard let captureSession = self?.captureSession else { return }
            do {
                try self?.beginSession()
                let preview = AVCaptureVideoPreviewLayer(session: captureSession)
                self?.previewLayer = preview
                guard let connection = self?.previewLayer?.connection else {
                    completion(preview)
                    return
                }
                connection.videoOrientation = DashcamHelpers.currentOrientationForAVCapture()
                completion(preview)
            } catch {
                assert(false, "Unable to initialize AVCapture video preview layer")
                completion(nil)
            }
        }
    }

    /// Will resume if needed
    func resumePreviewLayer() {
        guard self.captureSession.isRunning == false else { return }
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }

    /// Will pause if needed
    func pausePreviewLayer() {
        guard self.captureSession.isRunning == true else { return }
        sessionQueue.async {
            self.captureSession.stopRunning()
        }
    }

    func endSession() {
        NotificationCenter.default.removeObserver(self)

        guard captureSession.isRunning else { return }

        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.captureSession.stopRunning()
        }
    }

    public func handleDashcamAutostart() {
        if UserDefaults.dashcamAutomaticRecording, autostartShouldRecordFirstSessionFlag {
            startRecording()
            autostartShouldRecordFirstSessionFlag = false
        }
    }

    func startRecording() {
        setupUpdateLocationTimer()
        eraseAllVideos()
        loopCount = 0
        recordingOrientation = DashcamHelpers.currentOrientationForAVCapture()
        recording = true
        crashDetector.setEnabled(UserDefaults.dashcamCrashDetector)
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = self.getAVPreset(from: self.quality)
            self.captureSession.commitConfiguration()

            if self.recordAudio {
                try? self.configureSessionForAudioRecording()
            } else {
                self.configureSessionWithoutAudio()
            }
        }

        loopTimer = Timer.scheduledTimer(timeInterval: videoPartLength, target: self, selector: #selector(loopTimerSelector), userInfo: nil, repeats: true)
        loopTimer?.fire()
    }

    func stopRecording() {
        loopTimer = nil
        locationUpdateTimer = nil
        crashDetector.setEnabled(false)

        stopRecordingPart { [weak self] in
            guard let self = self else { return }
            self.recording = false

            self.imageProcessingQueue.async {
                self.saveVideo()
                self.configureSessionWithoutAudio()
            }

            self.videoWriter = nil
            self.videoWriterInput = nil
            self.audioWriterInput = nil
        }
    }
}

// MARK: - Export

private extension DashcamSession {
    func exportAssetQualityPresetName() -> String {
        let settingsPreset = getAVPreset(from: quality)

        switch settingsPreset {
        case .hd1920x1080:
            return AVAssetExportPreset1920x1080
        case .vga640x480:
            return AVAssetExportPreset640x480
        default:
            return AVAssetExportPreset1280x720
        }
    }

    func saveVideo() {
        exporting = true
        let sessionHasAudioInput: Bool
        if let audioInputInitialized = audioInputStored {
            sessionHasAudioInput = captureSession.inputs.contains(where: { input -> Bool in (input as? AVCaptureDeviceInput) == audioInputInitialized })
        } else {
            sessionHasAudioInput = false
        }
        let exportAudio: Bool = recordAudio && sessionHasAudioInput

        let composition = AVMutableComposition()
        guard let trackVideo: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID()) else { return }
        var trackAudio: AVMutableCompositionTrack?

        if exportAudio {
            trackAudio = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
        }

        var insertTime = CMTime.zero

        let recordedFiles = recordedFileNames()

        for (index, videoPart) in recordedFiles.enumerated() {
            let sourceAsset = AVURLAsset(url: URL(fileURLWithPath: filePath(videoPart)))

            let tracks = sourceAsset.tracks(withMediaType: .video)
            if tracks.count > 0 {
                let assetTrack: AVAssetTrack = tracks[0] as AVAssetTrack

                var startOffset = CMTime.zero
                var partDuration = sourceAsset.duration

                if index == 0, recordedFiles.count > 1, let lastRecodName = recordedFiles.last {
                    let lastAsset = AVURLAsset(url: URL(fileURLWithPath: filePath(lastRecodName)))
                    startOffset = lastAsset.duration
                    partDuration = CMTimeSubtract(sourceAsset.duration, lastAsset.duration)
                }

                try? trackVideo.insertTimeRange(CMTimeRangeMake(start: startOffset, duration: partDuration), of: assetTrack, at: insertTime)

                let audios = sourceAsset.tracks(withMediaType: .audio)
                if exportAudio && audios.count > 0 {
                    guard let trackAudio = trackAudio else { return }
                    let assetTrackAudio: AVAssetTrack = audios[0] as AVAssetTrack
                    try? trackAudio.insertTimeRange(CMTimeRangeMake(start: startOffset, duration: partDuration), of: assetTrackAudio, at: insertTime)
                }

                insertTime = CMTimeAdd(insertTime, partDuration)
            }
        }

        let fileName = "\(UUID())\(dashcamFileMark)final-movie.mp4"
        print(fileName)
        let outputPath = filePath(fileName)
        let outputURL = URL(fileURLWithPath: outputPath)

        guard let exporter = AVAssetExportSession(asset: composition, presetName: exportAssetQualityPresetName()) else { return }

        if ADASDebug.enabled {
            let seconds = CMTimeGetSeconds(insertTime)
            if !seconds.isNaN {
                let firstFrameTime = Date(timeInterval: -seconds, since: Date())
                let dateTimeStampString = String(firstFrameTime.timeIntervalSince1970 * 1000) + "_\(fileName)" as NSString
                let dateAssetMetadata = AVMutableMetadataItem()
                dateAssetMetadata.identifier = AVMetadataIdentifier.quickTimeMetadataTitle
                dateAssetMetadata.value = dateTimeStampString
                exporter.metadata = [dateAssetMetadata]
            }
        }

        exporter.outputURL = outputURL
        exporter.outputFileType = AVFileType.mp4
        exporter.exportAsynchronously {
            UISaveVideoAtPathToSavedPhotosAlbum(outputPath, self, #selector(self.exporterDidFinishSavingVideo(_:error:contextInfo:)), nil)
        }
    }

    @objc
    func exporterDidFinishSavingVideo(_ videoPath: String, error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        eraseAllVideos()
        exporting = false

        DispatchQueue.main.async {
            if let error = error {
                self.provider.showToast(message: "dashcam.toast.savingFailed".localized, icon: nil, error: error)
            } else {
                
                let icon = UIImage(named: "dashcam-success", in: .module, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
                self.provider.showToast(message: "dashcam.toast.videoSaved".localized, icon: icon, error: nil)
            }
        }
    }
}

// MARK: - Files management

private extension DashcamSession {
    func recordedFileNames() -> [String] {
        if let dirContent = try? FileManager.default.contentsOfDirectory(atPath: directoryPath) {
            let dashcamFiles = dirContent.filter { $0.contains(dashcamFileMark) }

            return dashcamFiles.sorted { [weak self] mov1, mov2 -> Bool in

                if let path1 = self?.filePath(mov1), let props1 = try? FileManager.default.attributesOfItem(atPath: path1),
                    let date1 = props1[FileAttributeKey.modificationDate] as? Date,
                    let path2 = self?.filePath(mov2), let props2 = try? FileManager.default.attributesOfItem(atPath: path2),
                    let date2 = props2[FileAttributeKey.modificationDate] as? Date {
                    return date1.compare(date2) == .orderedAscending
                }

                return true
            }
        }

        return []
    }

    func filePath(_ fileName: String) -> String {
        String(format: "%@%@", directoryPath, fileName)
    }

    func eraseAllVideos() {
        for file in recordedFileNames() {
            try? FileManager.default.removeItem(atPath: filePath(file))
        }
    }

    func eraseOldVideoParts() {
        let allFiles = recordedFileNames()
        let videoPartLengthInMinutes = videoPartLength / 60.0
        let totalVideoDurationInMinutes = allFiles.count * Int(videoPartLengthInMinutes)
        let exceededDuration = totalVideoDurationInMinutes - (maxTotalDashcamSessionDurationInMinutes + 1)
        if exceededDuration > 0 {
            let numberOfVideosToDelete = exceededDuration / Int(videoPartLengthInMinutes)
            if numberOfVideosToDelete > 0 {
                for index in 0 ..< numberOfVideosToDelete {
                    try? FileManager.default.removeItem(atPath: filePath(allFiles[index]))
                }
            }
        }
    }
}

// MARK: - Selectors

private extension DashcamSession {
    @objc
    func updateLocationUI() {
        if let positionInfo = self.currentPosition() {
            self.tempLocation = positionInfo
        }
    }

    // Called when media services are reset
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }

        /*
         Automatically try to restart the session running if media services were
         reset and the last start running succeeded.
         */
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.recording {
                    self.captureSession.startRunning()
                }
            }
        }
    }

    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        guard recording && recordingInterupted == false else { return }
        /*
         In some scenarios we want to enable the user to resume the session running.
         For example, if music playback is initiated via control center while
         using AVCam, then the user can let AVCam resume
         the session running, which will stop music playback. Note that stopping
         music playback in control center will not automatically resume the session
         running. Also note that it is not always possible to resume, see `resumeInterruptedSession(_:)`.
         */
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            if reason == .audioDeviceInUseByAnotherClient {
                recordingInterupted = true
                stopRecordingPart {
                    self.configureSessionWithoutAudio()
                    self.recordingInterupted = false
                    self.startRecordingPart()
                }
            } else if reason == .videoDeviceInUseByAnotherClient ||
                reason == .videoDeviceNotAvailableInBackground {
                recordingInterupted = true
                stopRecordingPart()
            } else {
                stopRecording()
            }
        }
    }

    /*
     This is received when user stops the interuption reason. For example: when user start music via controll centre, we get interuption, but than user stop music via controll center this method is called. However, it takes some time before we get this, so it might be good idea to display some resume button to resume session sooner.
     */
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        if recording && recordingInterupted {
            if recordAudio {
                try? configureSessionForAudioRecording()
            } else {
                configureSessionWithoutAudio()
            }
            recordingInterupted = false
            startRecordingPart()
        }
    }
}
