import Foundation

extension UserDefaults {
    static var dashcamTailgatingNotification: Bool {
        UserDefaults.standard.bool(forKey: Keys.dashcamTailgatingNotification)
    }

    static func setDashcamTailgatingNotification(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: Keys.dashcamTailgatingNotification)
    }

}
