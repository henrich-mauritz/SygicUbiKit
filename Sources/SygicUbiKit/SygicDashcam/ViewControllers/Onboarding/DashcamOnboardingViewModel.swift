import AVFoundation
import Foundation

// MARK: - DashcamOnboardingViewModel

final class DashcamOnboardingViewModel {
    var settingsDurationClosure: TextClosure?
    var settingsQualityClosure: TextClosure?
    var videoDurationClosure: TextClosure?

    private let session: DashcamSession

    private var settingsQualityButtonText: String = "" {
        willSet {
            settingsQualityClosure?(newValue)
        }
    }

    private var settingsDurationButtonText: String = "" {
        willSet {
            settingsDurationClosure?(newValue)
        }
    }

    private var videoDurationInfoText: String = "" {
        willSet {
            videoDurationClosure?(newValue)
        }
    }

    var quality: VideoQuality {
        VideoQuality(rawValue: UserDefaults.dashcamVideoQuality) ?? .SD
    }

    var duration: VideoDuration {
        VideoDuration(rawValue: UserDefaults.dashcamVideoDuration) ?? .min1
    }

    init(session: DashcamSession) {
        self.session = session
    }
}

extension DashcamOnboardingViewModel {
    func updateVideoDurationInfoText() {
        if isEnoughSpace().isEnough {
            let avaiableDurationString = isEnoughSpace().availableDuration
            var text = String(format: "dashcam.onboarding.freeSpaceEnough".localized, avaiableDurationString)
            text = text.insertJoinWordCharacterAfter("\(avaiableDurationString)")
            videoDurationInfoText = text
        } else {
            videoDurationInfoText = "dashcam.onboarding.freeSpaceNotEnough".localized
        }
    }

    func isEnoughSpace() -> (isEnough: Bool, availableDuration: Int64) {
        guard let freeBytes = try? DashcamOnboardingViewModel.freeDiskSpaceInBytes() else { return (false, 0) }

        let approximatedSize: Int64 = ApproximatedSize.minuteVideoSize(with: session.getAVPreset(from: quality)).rawValue

        guard approximatedSize != 0 else { return (false, 0) }

        let availableDuration = freeBytes / approximatedSize

        return (availableDuration >= UserDefaults.dashcamVideoDuration, availableDuration)
    }

    func setDefaults() {
        updateVideoDuration(duration.localizedText)
        updateVideoQuality(quality.localizedText)
        UserDefaults.setDashcamVideoDuration(duration)
        UserDefaults.setDashcamVideoQuality(quality)
    }
}

// MARK: - Private

private extension DashcamOnboardingViewModel {
    func updateVideoDuration(_ videoDuration: String) {
        settingsDurationButtonText = videoDuration
        updateVideoDurationInfoText()
    }

    func updateVideoQuality(_ videoQuality: String) {
        settingsQualityButtonText = videoQuality
        updateVideoDurationInfoText()
    }

    enum ApproximatedSize: Int64 {
        case unknown = 0
        case vga = 13000000
        case hd720 = 49000000
        case hd1080 = 110000000

        static func minuteVideoSize(with preset: AVCaptureSession.Preset) -> ApproximatedSize {
            switch preset {
            case .vga640x480:
                return vga
            case .hd1280x720:
                return hd720
            case .hd1920x1080:
                return hd1080
            default:
                return unknown
            }
        }
    }
}

extension DashcamOnboardingViewModel {
    static func freeDiskSpaceInBytes() throws -> Int64 {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
            return freeSpace!
        } catch {
            throw error
        }
    }
}

// MARK: DashcamOnboardingPickerDelegate

extension DashcamOnboardingViewModel: DashcamOnboardingPickerDelegate {
    func didSelect(option: DashcamOption, pickerType: DashcamOnboardingPickerType) {
        switch pickerType {
        case .duration:
            let value = VideoDuration(rawValue: option.optionToSave) ?? .min5
            UserDefaults.setDashcamVideoDuration(value)
            updateVideoDuration(option.title)
        case .quality:
            let value = VideoQuality(rawValue: option.optionToSave) ?? .HD
            UserDefaults.setDashcamVideoQuality(value)
            updateVideoQuality(option.title)
        }
    }
}
