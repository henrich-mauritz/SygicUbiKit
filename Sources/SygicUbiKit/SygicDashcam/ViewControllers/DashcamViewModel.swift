import AVFoundation
import Foundation

// MARK: - DashcamViewModel

final class DashcamViewModel {
    var isRecordingClosure: ((_ recording: Bool) -> Void)?
    var isExportingClosure: ((_ exporting: Bool) -> Void)?

    private let session: DashcamSession

    var inTrip: Bool { return session.provider.inTrip }
    init(session: DashcamSession) {
        self.session = session

        session.recordingClosure = { [weak self] recording in
            self?.isRecordingClosure?(recording)
        }

        session.exportingClosure = { [weak self] exporting in
            self?.isExportingClosure?(exporting)
        }
    }

    deinit {
        if session.recording == false {
            session.endSession()
        }
    }
}

extension DashcamViewModel {
    func loadCameraPreviewLayer(completion: @escaping ((_ layer: AVCaptureVideoPreviewLayer?) -> Void)) {
        session.setupPreviewLayer(completion: completion)
        session.resumePreviewLayer()
    }

    func toggleRecording() {
        guard !session.exporting else { return }

        if session.recording {
            AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.dashcamStopRecording, parameters: nil)
            session.stopRecording()
        } else {
            session.startRecording()
            AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.dashcamStartRecording, parameters: nil)
        }
    }

    func pauseCameraPreviewLayer() {
        session.pausePreviewLayer()
    }
}
