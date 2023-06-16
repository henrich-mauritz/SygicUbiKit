import UIKit

public extension UIFont {
    enum FontType {
        case thin
        case light
        case regular
        case semibold
        case bold

        var stylingFontName: String? {
            switch self {
            case .thin:
                return Styling.thinFontName
            case .light:
                return Styling.lightFontName
            case .regular:
                return Styling.regularFontName
            case .semibold:
                return Styling.semiboldFontName
            case .bold:
                return Styling.boldFontName
            }
        }

        var weight: UIFont.Weight {
            switch self {
            case .thin:
                return .thin
            case .light:
                return .light
            case .regular:
                return .regular
            case .semibold:
                return .semibold
            case .bold:
                return .bold
            }
        }
    }

    static func stylingFont(_ type: FontType = .regular, with size: CGFloat) -> UIFont {
        if let fontName = type.stylingFontName, let font = UIFont(name: fontName, size: size) {
            return font
        } else {
            return UIFont.systemFont(ofSize: size, weight: type.weight)
        }
    }

    static func bigTitleFont() -> UIFont {
        stylingFont(.thin, with: 28)
    }

    static func buttonFont() -> UIFont {
        stylingFont(.semibold, with: 20)
    }

    static func itemTitleFont() -> UIFont {
        stylingFont(.regular, with: 16)
    }

    static func itemSubtitleFont() -> UIFont {
        stylingFont(.regular, with: 10)
    }
}
