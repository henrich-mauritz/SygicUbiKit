import UIKit

final class DashcamColorManager {
    static let shared = DashcamColorManager()

    private(set) var isDark = false

    var title: UIColor {
        isDark ? .textTitleWhite : .textTitleBlack
    }

    var subtitle: UIColor {
        isDark ? .textBodyBlack : .textBodyBlack
    }

    var titleInvert: UIColor {
        isDark ? .textTitleBlack : .textTitleWhite
    }

    var blue: UIColor {
        isDark ? .blueDark : .blueLight
    }

    var blueIcon: UIColor {
        isDark ? .blueDark : .blueIcon
    }

    var background: UIColor {
        isDark ? .textTitleBlack : .white
    }

    var bar: UIColor {
        isDark ? .barDark : .barLight
    }

    func setTheme(dark: Bool) {
        isDark = dark
    }

    var backgroundColor: UIColor {
        isDark ? Styling.backgroundDriving : .backgroundOnboarding
    }
}
