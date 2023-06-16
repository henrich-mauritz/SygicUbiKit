import Foundation
import UIKit

// MARK: - StylingButtonStyle

public class StylingButtonStyle: StylingButtonType, InjectableType {
    /// Style initialized.
    /// - Returns: returns by default normal style
    fileprivate class func style() -> StylingButtonType {
        return StylingButtonNormalStyle.style()
    }

    public class func normalStyle() -> StylingButtonType {
        let style = StylingButtonNormalStyle.style()
        return style
    }

    public class func barStyle() -> StylingButtonType {
        let style = StylingButtonBarStyle.style()
        return style
    }

    public class func textIconStyle() -> StylingButtonType {
        let style = StylingButtonTextIconStyle.style()
        return style
    }

    public class func plainIconStyle() -> StylingButtonType {
        let style = StylingButtonPlainStyle.style()
        return style
    }

    public class func secondaryPlain() -> StylingButtonType {
        let style = StylingButtonSecondaryStyle.style()
        return style
    }

    public class func tertiaryStyle() -> StylingButtonType {
        let style = StylingButtonTertiaryStyle.style()
        return style
    }

    public class func normalModalStyle() -> StylingButtonType {
        return StylingButtonNormalModalStyle.style()
    }

    public class func secondaryModalStyle() -> StylingButtonType {
        return StylginButtonSecondaryModalStyle.style()
    }

    public class func circularStyle() -> StylingButtonType {
        return StylingButtonCircularStyle.style()
    }

    public var titleFont: UIFont?
    public var height: CGFloat = 48
    public var radius: CGFloat = Styling.cornerRadius
    public var textAlignment: NSTextAlignment = .center
    public var titleColor: UIColor = .buttonForegroundPrimary
    public var filled: Bool = true
    public var backgroundColor: UIColor = .buttonBackgroundPrimary
    public var stroked: Bool = false
    public var strokeColor: UIColor = .buttonForegroundPrimary
    public var lineWidth: CGFloat = 2.0
    public var icon: UIImage?

    public init(titleFont: UIFont?) {
        self.titleFont = titleFont
    }
}

// MARK: - StylingButtonNormalStyle

public final class StylingButtonNormalStyle: StylingButtonStyle {
    override class func style() -> StylingButtonType {
        let font: UIFont = UIFont.stylingFont(.bold, with: 16)
        let style = StylingButtonNormalStyle(titleFont: font)
        return style
    }
}

// MARK: - StylingButtonBarStyle

public final class StylingButtonBarStyle: StylingButtonStyle {
    override class func style() -> StylingButtonType {
        let font: UIFont = UIFont.stylingFont(.regular, with: 14)
        let style = StylingButtonBarStyle(titleFont: font)
        style.height = 28
        style.radius = Styling.cornerRadiusSecondary
        return style
    }
}

// MARK: - StylingButtonTextIconStyle

public final class StylingButtonTextIconStyle: StylingButtonStyle {
    override class func style() -> StylingButtonType {
        let font: UIFont = UIFont.stylingFont(.regular, with: 20)
        let style = StylingButtonTextIconStyle(titleFont: font)
        style.textAlignment = .natural
        return style
    }
}

// MARK: - StylingButtonPlainStyle

public final class StylingButtonPlainStyle: StylingButtonStyle {
    override class func style() -> StylingButtonType {
        let font: UIFont = UIFont.stylingFont(.regular, with: 14)
        let style = StylingButtonPlainStyle(titleFont: font)
        style.backgroundColor = .clear
        style.titleColor = .actionPrimary
        style.height = 20
        return style
    }
}

// MARK: - StylingButtonSecondaryStyle

public final class StylingButtonSecondaryStyle: StylingButtonStyle {
    override class func style() -> StylingButtonType {
        let font: UIFont = UIFont.stylingFont(.bold, with: 16)
        let secondaryStyle = StylingButtonSecondaryStyle(titleFont: font)
        secondaryStyle.titleColor = .buttonForegroundSecondary
        secondaryStyle.backgroundColor = .buttonBackgroundSecondary
        return secondaryStyle
    }
}

// MARK: - StylingButtonTertiaryStyle

public final class StylingButtonTertiaryStyle: StylingButtonStyle {
    override class func style() -> StylingButtonType {
        let font: UIFont = UIFont.stylingFont(.bold, with: 20)
        let style = StylingButtonNormalStyle(titleFont: font)
        style.backgroundColor = .buttonBackgroundTertiaryActive
        style.titleColor = .buttonForegroundTertiaryActive
        return style
    }
}

// MARK: - StylingButtonNormalModalStyle

public final class StylingButtonNormalModalStyle: StylingButtonStyle {
    override class func style() -> StylingButtonType {
        let font: UIFont = UIFont.stylingFont(.bold, with: 16)
        let style = StylingButtonNormalStyle(titleFont: font)
        style.backgroundColor = .buttonBackgroundModalPrimary
        return style
    }
}

// MARK: - StylginButtonSecondaryModalStyle

public final class StylginButtonSecondaryModalStyle: StylingButtonStyle {
    override class func style() -> StylingButtonType {
        let font: UIFont = UIFont.stylingFont(.bold, with: 16)
        let secondaryStyle = StylingButtonSecondaryStyle(titleFont: font)
        secondaryStyle.titleColor = .buttonForegroundSecondary
        secondaryStyle.backgroundColor = .buttonBackgroundModalSecondary
        return secondaryStyle
    }
}

// MARK: - StylingButtonCircularStyle

public final class StylingButtonCircularStyle: StylingButtonStyle {
    override class func style() -> StylingButtonType {
        let style = StylingButtonCircularStyle(titleFont: nil)
        style.height = 70
        style.radius = style.height / 2
        return style
    }
}
