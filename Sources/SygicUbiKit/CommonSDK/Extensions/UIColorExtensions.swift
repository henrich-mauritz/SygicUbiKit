import UIKit

public extension UIColor {
    //MARK: Backgrounds

    static var backgroundPrimary: UIColor { Styling.backgroundPrimary }
    static var backgroundSecondary: UIColor { Styling.backgroundSecondary }
    static var backgroundTertiary: UIColor { Styling.backgroundTertiary }
    static var backgroundOverlay: UIColor { Styling.backgroundOverlay }
    static var backgroundDriving: UIColor { Styling.backgroundDriving }
    static var backgroundModal: UIColor { Styling.backgroundModal }
    static var backgroundOnboarding: UIColor { Styling.backgroundOnboarding }
    static var backgroundToast: UIColor { Styling.backgroundToast }

    //MARK: Foregrounds

    static var foregroundPrimary: UIColor { Styling.foregroundPrimary }
    static var foregroundSecondary: UIColor { Styling.foregroundSecondary }
    static var foregroundTertiary: UIColor { Styling.foregroundTertiary }
    static var foregroundDriving: UIColor { Styling.foregroundDriving }
    static var foregroundModal: UIColor { Styling.foregroundModal }
    static var foregroundOnboarding: UIColor { Styling.foregroundOnboarding }
    static var foregroundToast: UIColor { Styling.foregroundToast }

    //MARK: Accent

    static var positivePrimary: UIColor { Styling.positivePrimary }
    static var negativePrimary: UIColor { Styling.negativePrimary }
    static var negativeSecondary: UIColor { Styling.negativeSecondary }
    static var negativeSeverityLow: UIColor { Styling.negativeSeverityLow }
    static var negativeSeverityMedium: UIColor { Styling.negativeSeverityMedium }
    static var negativeSeverityHigh: UIColor { Styling.negativeSeverityHigh }
    static var badgeBackgroundEarned: UIColor { Styling.badgeBackgroundEarned }
    static var badgeBackgroundUnearned: UIColor { Styling.badgeBackgroundUnearned }

    //MARK: Buttons and 'Call to actions'

    static var actionPrimary: UIColor { Styling.actionPrimary }
    static var buttonBackgroundPrimary: UIColor { Styling.buttonBackgroundPrimary }
    static var buttonForegroundPrimary: UIColor { Styling.buttonForegroundPrimary }
    static var buttonBackgroundSecondary: UIColor { Styling.buttonBackgroundSecondary }
    static var buttonForegroundSecondary: UIColor { Styling.buttonForegroundSecondary }
    static var buttonBackgroundTertiaryActive: UIColor { Styling.buttonBackgroundTertiaryActive }
    static var buttonBackgroundTertiaryPassive: UIColor { Styling.buttonBackgroundTertiaryPassive }
    static var buttonForegroundTertiaryActive: UIColor { Styling.buttonForegroundTertiaryActive }
    static var buttonForegroundTertiaryPassive: UIColor { Styling.buttonForegroundTertiaryPassive }
    static var buttonBackgroundModalSecondary: UIColor { Styling.buttonBackgroundModalSecondary }
    static var buttonBackgroundModalPrimary: UIColor { Styling.buttonBackgroundModalPrimary }
    static var buttonOnboardingSecondaryBackground: UIColor { Styling.buttonOnboardingSecondaryBackground }

    //MARK: Custom

    static var shadowPrimary: UIColor { Styling.shadowPrimary }
    static var mapRoute: UIColor { Styling.mapRoute }
    static var mapPin: UIColor { Styling.mapPin }
    static var floatingBarBackground: UIColor { Styling.floatingBarBackground }
    @available(*, deprecated, message: "Please use .backgroundOverlay instead")
    static var drivingStartBackground: UIColor { Styling.drivingStartBackground }
    @available(*, deprecated, message: "Please use .actionPrimary or .buttonBackgroundPrimary instead")
    static var accent: UIColor { Styling.actionPrimary }
    @available(*, deprecated, message: "Please use .backgroundSecondary instead")
    static var accentSecondary: UIColor { Styling.backgroundSecondary }
    @available(*, deprecated, message: "Please use .negativePrimary instead")
    static var warnings: UIColor { Styling.negativePrimary }
    @available(*, deprecated, message: "Please use .negativeSecondary instead")
    static var warningsSecondary: UIColor { Styling.negativeSecondary }
    @available(*, deprecated, message: "Please use .backgroundPrimary instead")
    static var primary: UIColor { Styling.backgroundPrimary }
    @available(*, deprecated, message: "Please use .backgroundModal instead")
    static var modalPrimary: UIColor { Styling.backgroundModal }
    @available(*, deprecated, message: "Please use .backgroundDriving instead")
    static var secondary: UIColor { Styling.backgroundDriving }
    @available(*, deprecated, message: "Please use .backgroundSecondary instead")
    static var semitransparent: UIColor { Styling.backgroundSecondary }
    @available(*, deprecated, message: "Please use .backgroundSecondary or .backgroundOverlay instead")
    static var semitransparent2: UIColor { Styling.backgroundSecondary }
    @available(*, deprecated, message: "Please use .foregroundPrimary instead")
    static var textPrimary: UIColor { Styling.foregroundPrimary }
    @available(*, deprecated, message: "Please use .foregroundDriving instead")
    static var textSecondary: UIColor { Styling.foregroundDriving }
    @available(*, deprecated, message: "Please use .clear instead")
    static var fullTransparent: UIColor { .clear }
    @available(*, deprecated, message: "Please use .buttonForegroundPrimary instead")
    static var elementSelected: UIColor { Styling.buttonForegroundPrimary }
    @available(*, deprecated, message: "Please use .positivePrimary instead")
    static var progress: UIColor { Styling.positivePrimary }
    @available(*, deprecated, message: "Please use .negativeSecondary instead")
    static var lowScore: UIColor { Styling.negativeSecondary }
    @available(*, deprecated, message: "Please use .buttonForegroundPrimary instead")
    static var foreground: UIColor { Styling.buttonForegroundPrimary }
    @available(*, deprecated, message: "Please use .backgroundOnboarding instead")
    static var onboardingBackground: UIColor { Styling.backgroundOnboarding }
    @available(*, deprecated, message: "Please use .backgroundSecondary instead")
    static var backgroundAppSecondary: UIColor { Styling.backgroundSecondary }

    //MARK: Driving event colors

    static var distraction: UIColor { Styling.eventDistraction }
    static var speeding: UIColor { Styling.eventSpeeding }
    static var accelerating: UIColor { Styling.eventAccelerating }
    static var braking: UIColor { Styling.eventBraking }
    static var cornering: UIColor { Styling.eventCornering }

    //MARK: Severity colors

    @available(*, deprecated, message: "Please use .negativeSeverityLow instead")
    static var lowSeverityLevel: UIColor { Styling.negativeSeverityLow }
    @available(*, deprecated, message: "Please use .negativeSeverityMedium instead")
    static var mediumSeverityLevel: UIColor { Styling.negativeSeverityMedium }
    @available(*, deprecated, message: "Please use .negativeSeverityHigh instead")
    static var highSeverityLevel: UIColor { Styling.negativeSeverityHigh }

    //MARK: UIComponents

    static var switchTintColor: UIColor { Styling.switchTintColor }
    static var switchTintDisableColor: UIColor { Styling.switchTintDisableColor }

    func cgColor(with traitCollection: UITraitCollection) -> CGColor {
        return resolvedColor(with: traitCollection).cgColor
    }

    /// Returns a static UIColor resolved with dark user interface style on ios 13 and default style on lower
    var darkStyle: UIColor {
        return resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
    }

    var hexString: String? {
        if let components = self.cgColor.components {
            let r = components[0]
            let g = components[1]
            let b = components[2]
            return String(format: "#%02x%02x%02x", (Int)(r * 255), (Int)(g * 255), (Int)(b * 255))
        }
        return nil
    }

    /// Returns a static UIColor resolved with dark user interface style on ios 13 and default style on lower
    var invertedTheme: UIColor {
        let style: UIUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .light : .dark
        return resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
    }

    func lighter(amount: CGFloat = 0.25) -> UIColor {
        return hueColorWithBrightnessAmount(amount: 1 + amount)
    }

    func darker(amount: CGFloat = 0.25) -> UIColor {
        return hueColorWithBrightnessAmount(amount: 1 - amount)
    }

    private func hueColorWithBrightnessAmount(amount: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue,
                           saturation: saturation,
                           brightness: brightness * amount,
                           alpha: alpha)
        } else {
            return self
        }
    }
    
}
