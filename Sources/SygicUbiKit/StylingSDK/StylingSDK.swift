import UIKit

///Colors can be redefined inside the app
public class Styling {
    //MARK: - Colors

    //MARK: Backgrounds

    public static var backgroundPrimary: UIColor = .white
    public static var backgroundSecondary: UIColor = .lightGray
    public static var backgroundTertiary: UIColor = .gray
    public static var backgroundOverlay: UIColor = .black
    public static var backgroundDriving: UIColor = .gray
    public static var backgroundModal: UIColor = .gray
    public static var backgroundOnboarding: UIColor = .gray
    public static var backgroundToast: UIColor = .darkGray

    //MARK: Foregrounds

    public static var foregroundPrimary: UIColor = .black
    public static var foregroundSecondary: UIColor = .black
    public static var foregroundTertiary: UIColor = .white
    public static var foregroundDriving: UIColor = .white
    public static var foregroundModal: UIColor = .black
    public static var foregroundOnboarding: UIColor = .black
    public static var foregroundToast: UIColor = .white

    //MARK: Accent

    public static var positivePrimary: UIColor = .green
    public static var negativePrimary: UIColor = .red // TODO bolo red2, padalo to, treba preskumat
    public static var negativeSecondary: UIColor = .orange
    public static var negativeSeverityLow: UIColor = Styling.negativePrimary.withAlphaComponent(0.4)
    public static var negativeSeverityMedium: UIColor = Styling.negativePrimary.withAlphaComponent(0.7)
    public static var negativeSeverityHigh: UIColor = Styling.negativePrimary
    public static var mapRoute: UIColor = .blue
    public static var mapPin: UIColor = .blue
    public static var floatingBarBackground: UIColor = .gray
    public static var badgeBackgroundEarned: UIColor = .magenta
    public static var badgeBackgroundUnearned: UIColor = .gray

    //MARK: Buttons and 'Call to actions'

    public static var actionPrimary: UIColor = .systemPurple
    public static var buttonBackgroundPrimary: UIColor = .systemPurple
    public static var buttonForegroundPrimary: UIColor = .white
    public static var buttonBackgroundSecondary: UIColor = .lightGray
    public static var buttonForegroundSecondary: UIColor = .black
    public static var buttonBackgroundTertiaryActive: UIColor = .white
    public static var buttonBackgroundTertiaryPassive: UIColor = .black.withAlphaComponent(0.5)
    public static var buttonForegroundTertiaryActive: UIColor = .black
    public static var buttonForegroundTertiaryPassive: UIColor = .white
    public static var buttonBackgroundModalSecondary: UIColor = .lightGray
    public static var buttonBackgroundModalPrimary: UIColor = .systemPurple
    public static var buttonOnboardingSecondaryBackground: UIColor = .lightGray
    public static var shadowPrimary: UIColor = UIColor.black.withAlphaComponent(0.2)
    public static var textFieldBackgroundPrimary: UIColor = .white

    //Cell layout
    public static var cellLayoutMargin: CGFloat = 16.0

    //MARK: OLD ONES

    @available(*, deprecated, message: "Use .actionPrimary instead. This Use .color instead. This will be removed in next release!!")
    public static var accent: UIColor = .systemPurple
    @available(*, deprecated, message: "Use .negativePrimary instead. This will be removed in next release!")
    public static var warnings: UIColor = .red2
    @available(*, deprecated, message: "Use .negativeSecondary instead. This will be removed in next release!")
    public static var warningsSecondary: UIColor = .orange
    @available(*, deprecated, message: "Use .backgroundSecondary instead. This will be removed in next release!")
    public static var accentSecondary: UIColor = .white
    @available(*, deprecated, message: "Use .backgroundPrimary instead. This will be removed in next release!")
    public static var primary: UIColor = .darkGray
    @available(*, deprecated, message: "Use .backgroundModal instead. This will be removed in next release!")
    public static var modalPrimary: UIColor = .lightGray
    @available(*, deprecated, message: "Use .backgroundDriving instead. This will be removed in next release!")
    public static var secondary: UIColor = .gray
    @available(*, deprecated, message: "Use .backgroundSecondary instead. This will be removed in next release!")
    public static var semitransparent: UIColor = UIColor.black.withAlphaComponent(0.3)
    @available(*, deprecated, message: "Use .backgroundSecondary or .backgroundOverlay with alpha instead. This will be removed in next release!")
    public static var semitransparent2: UIColor = UIColor.black.withAlphaComponent(0.15)
    @available(*, deprecated, message: "Use .foregroundPrimary instead. This will be removed in next release!")
    public static var textPrimary: UIColor = UIColor.black
    @available(*, deprecated, message: "Use .foregroundDriving instead. This will be removed in next release!")
    public static var textSecondary: UIColor = UIColor.black.withAlphaComponent(0.8)
    @available(*, deprecated, message: "Use .clear instead. This will be removed in next release!")
    public static var fullTransparent: UIColor = .clear
    @available(*, deprecated, message: "Use .buttonForegroundPrimary instead. This will be removed in next release!")
    public static var elementSelected: UIColor = .white
    @available(*, deprecated, message: "Use .positivePrimary instead. This will be removed in next release!")
    public static var progress: UIColor = .green
    @available(*, deprecated, message: "Use .buttonForegroundPrimary instead. This will be removed in next release!")
    public static var foreground: UIColor = UIColor(white: 0.18, alpha: 1)
    @available(*, deprecated, message: "Use .backgroundOnboarding instead. This will be removed in next release!")
    public static var onboardingBackground: UIColor = .darkGray
    @available(*, deprecated, message: "Use UIColor.color.invertedTheme instead. This will be removed in next release!")
    public static var primaryInverted: UIColor = .white
    @available(*, deprecated, message: "Use UIColor.color.invertedTheme instead. This will be removed in next release!")
    public static var textPrimaryInverted: UIColor = .darkGray
    @available(*, deprecated, message: "Use .negativeSecondary instead. This will be removed in next release!")
    public static var lowScore: UIColor = .orange
    @available(*, deprecated, message: "Use .backgroundOverlay instead. This will be removed in next release!")
    public static var semitransparent50p: UIColor = UIColor.black.withAlphaComponent(0.5)
    @available(*, deprecated, message: "Use .backgroundSecondary instead. This will be removed in next release!")
    public static var backgroundAppSecondary: UIColor = .lightGray
    @available(*, deprecated, message: "Use .negativeSeverityLow instead. This will be removed in next release!")
    public static var lowSeverityLevel: UIColor = Styling.warnings.withAlphaComponent(0.3)
    @available(*, deprecated, message: "Use .negativeSeverityMedium instead. This will be removed in next release!")
    public static var mediumSeverityLevel: UIColor = Styling.warnings.withAlphaComponent(0.6)
    @available(*, deprecated, message: "Use .negativeSeverityHigh instead. This will be removed in next release!")
    public static var highSeverityLevel: UIColor = Styling.warnings
    @available(*, deprecated, message: "Use .backgroundOverlay instead. This will be removed in next release!")
    public static var drivingStartBackground: UIColor = UIColor.black.withAlphaComponent(0.3)

    //MARK: UIComponents

    public static var switchTintColor: UIColor = .green
    public static var switchTintDisableColor: UIColor = .lightGray

    //MARK: Events colors

    public static var eventBraking: UIColor = .yellow
    public static var eventAccelerating: UIColor = .blue
    public static var eventDistraction: UIColor = .orange
    public static var eventCornering: UIColor = .green
    public static var eventSpeeding: UIColor = .red2

    //MARK: - Custom font names can be defined by app

    public static var thinFontName: String? //= "SFUIText-Regular"
    public static var regularFontName: String?
    public static var semiboldFontName: String?
    public static var boldFontName: String?
    public static var lightFontName: String?

    //MARK: - Corner radius

    public static var cornerRadius: CGFloat = 16
    public static var cornerRadiusSecondary: CGFloat = 10
    public static var cornerRadiusModalPopup: CGFloat = 32
    public static var segmentedControlCornerRadius: CGFloat = cornerRadiusSecondary
    public static var driveSliderKnowCornerRadious: CGFloat = 26
    public static var driveSliderButtonCorenerRadius: CGFloat = 20

    //MARK: - Alpha opacity

    ///HighlightedStates
    public static var highlightedStateAlpha: CGFloat = 0.8
    ///DisabledStates
    public static var disabledStateAlpha: CGFloat = 0.4

//MARK: - Styles

    //MARK: Defined Styles

    public enum Style {
        case roundedWithDropShadowStyle(cornerRadius: CGFloat, shadowColor: UIColor, shadowOffset: CGSize, shadowRadius: CGFloat)
        case roundedCornersStyle(cornerRadius: CGFloat)
        case secondaryRoundeCornerStyle(cornerRadius: CGFloat)
    }

    public static var roundedWithDropShadowStyle: Style = .roundedWithDropShadowStyle(cornerRadius: Styling.cornerRadius,
                                                                                      shadowColor: Styling.shadowPrimary, shadowOffset: CGSize(width: 0, height: 4),
                                                                                      shadowRadius: 6.0)

    public static var roundedConrnerSytle: Style = .roundedCornersStyle(cornerRadius: Styling.cornerRadius)
    public static var smallRoundedCornerStyle: Style = .secondaryRoundeCornerStyle(cornerRadius: Styling.cornerRadiusSecondary)
}
