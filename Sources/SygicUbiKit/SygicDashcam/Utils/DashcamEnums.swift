import Foundation

// MARK: - DashcamError

public enum DashcamError: Error {
    case noVideoInput
    case noAudioInput
    case sessionNotActivated
}

// MARK: - VideoQuality

public enum VideoQuality: Int {
    case VGA = 0, SD = 1, HD = 2

    var localizedText: String {
        switch self {
        case .HD: return "dashcam.settings.videoQualityHD".localized
        case .SD: return "dashcam.settings.videoQualitySD".localized
        case .VGA: return "dashcam.settings.videoQualityVGA".localized
        }
    }
}

// MARK: - VideoDuration

public enum VideoDuration: Int {
    case min1 = 1, min5 = 5, min10 = 10, min15 = 15

    var localizedText: String {
        switch self {
        case .min1: return "dashcam.settings.duration1".localized
        case .min5: return "dashcam.settings.duration5".localized
        case .min10: return "dashcam.settings.duration10".localized
        case .min15: return "dashcam.settings.duration15".localized
        }
    }
}
