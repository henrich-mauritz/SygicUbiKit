import UIKit
import AVFoundation
import Photos

enum DashcamHelpers {
    static var allPermissionsAllowed: Bool {
        let videoAccessStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let photosAccessStatus = PHPhotoLibrary.authorizationStatus()

        return (videoAccessStatus == .authorized && photosAccessStatus == .authorized)
    }

    static func currentOrientationForAVCapture() -> AVCaptureVideoOrientation {
        UIDevice.current.orientation.orientationForAVCapture()
    }

    static func currentOrientation() -> UIInterfaceOrientation {
        return UIWindow.screenOrientation
    }

    static func availableDashcamVideoDurationOptions() -> [DashcamOption] {
        let options: [DashcamOption] = [
            (VideoDuration.min15.rawValue, "15"),
            (VideoDuration.min10.rawValue, "10"),
            (VideoDuration.min5.rawValue, "5"),
            (VideoDuration.min1.rawValue, "1"),
        ]

        return options.map { option -> DashcamOption in
            (option.optionToSave, "\(option.title) min")
        }
    }

    static func availableDashcamVideoQualityOptions() -> [DashcamOption] {
        var optionToSave: Int = 0
        var locationToSave: String = ""

        return availableVideoPresets().map { preset -> DashcamOption in
            switch preset {
            case .hd1920x1080:
                optionToSave = VideoQuality.HD.rawValue
                locationToSave = "dashcam.settings.videoQualityHD".localized
            case .hd1280x720:
                optionToSave = VideoQuality.SD.rawValue
                locationToSave = "dashcam.settings.videoQualitySD".localized
            case .vga640x480:
                optionToSave = VideoQuality.VGA.rawValue
                locationToSave = "dashcam.settings.videoQualityVGA".localized
            default:
                break
            }

            return (optionToSave, locationToSave)
        }
    }

    static func availableVideoPresets() -> [AVCaptureSession.Preset] {
        let backCamera = AVCaptureDevice.default(for: .video)
        let allPresets: [AVCaptureSession.Preset] = [.hd1920x1080, .hd1280x720, .vga640x480]
        var supportedPresets = [AVCaptureSession.Preset]()

        allPresets.forEach {
            if backCamera?.supportsSessionPreset($0) != nil {
                supportedPresets.append($0)
            }
        }

        return supportedPresets
    }
}
