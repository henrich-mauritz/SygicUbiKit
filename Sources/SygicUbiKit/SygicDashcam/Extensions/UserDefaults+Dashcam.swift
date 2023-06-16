import Foundation

extension UserDefaults {
    enum Keys {
        static let dashcamSoundEnabled = "dashcamSoundEnabled"
        static let dashcamVideoDuration = "dashcamVideoDuration"
        static let dashcamVideoQuality = "dashcamVideoQuality"
        static let dashcamShouldShowOverlay = "dashcamShouldShowOverlay"
        static let dashcamAutomaticRecording = "dashcamAutomaticRecording"
        static let dashcamCrashDetector = "dashcamCrashDetector"
        static let dashcamOneTap = "dashcamOneTap"
        static let dashcamOnboardingSeen = "dashcamOnboardingSeen"
        static let onboardingComplete = "onboardingComplete"
        static let dashcamTailgatingNotification = "dashcamTailgatingNotification"
    }

    static func setDashcamSoundEnabled(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: Keys.dashcamSoundEnabled)
    }

    static func setDashcamVideoDuration(_ duration: VideoDuration) {
        UserDefaults.standard.set(duration.rawValue, forKey: Keys.dashcamVideoDuration)
    }

    static func setDashcamVideoQuality(_ quality: VideoQuality) {
        UserDefaults.standard.set(quality.rawValue, forKey: Keys.dashcamVideoQuality)
    }

    static func setDashcamShouldShowOverlay(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: Keys.dashcamShouldShowOverlay)
    }

    static func setDashcamAutomaticRecording(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: Keys.dashcamAutomaticRecording)
    }

    static func setDashcamOneTap(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: Keys.dashcamOneTap)
    }

    static func setDashcamCrashDetector(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: Keys.dashcamCrashDetector)
    }

    static func setDashcamOnboardingSeen() {
        UserDefaults.standard.set(true, forKey: Keys.dashcamOnboardingSeen)
    }

    static func setDashcamOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: Keys.onboardingComplete)
    }
}

// MARK: - Retrieving

public extension UserDefaults {
    static var dashcamSoundEnabled: Bool {
        UserDefaults.standard.bool(forKey: Keys.dashcamSoundEnabled)
    }

    static var dashcamVideoDuration: Int {
        UserDefaults.standard.integer(forKey: Keys.dashcamVideoDuration)
    }

    static var dashcamVideoQuality: Int {
        UserDefaults.standard.integer(forKey: Keys.dashcamVideoQuality)
    }

    static var dashcamShouldShowOverlay: Bool {
        UserDefaults.standard.bool(forKey: Keys.dashcamShouldShowOverlay)
    }

    static var dashcamAutomaticRecording: Bool {
        UserDefaults.standard.bool(forKey: Keys.dashcamAutomaticRecording)
    }

    static var dashcamOneTap: Bool {
        UserDefaults.standard.bool(forKey: Keys.dashcamOneTap)
    }

    static var dashcamCrashDetector: Bool {
        let key = Keys.dashcamCrashDetector
        guard UserDefaults.standard.value(forKey: key) != nil else { return true }
        return UserDefaults.standard.bool(forKey: key)
    }

    static var dashcamOnboardingSeen: Bool {
        UserDefaults.standard.bool(forKey: Keys.dashcamOnboardingSeen)
    }

    static var dashcamOnboardingComplete: Bool {
        UserDefaults.standard.bool(forKey: Keys.onboardingComplete)
    }
}
