import UIKit

public extension UINavigationController {
    func setup(with style: StylingNavigationControllerStyle) {
        navigationBar.prefersLargeTitles = style.prefersLargeTitles
        navigationBar.largeTitleTextAttributes = style.largeTitleTextAttributes
        navigationBar.titleTextAttributes = style.titleTextAttributes
        navigationBar.setBackgroundImage(style.backgroundImage, for: .default)
        navigationBar.shadowImage = style.shadowImage
        navigationBar.isTranslucent = style.isTranslucent
        navigationBar.tintColor = style.tintColor
        view.backgroundColor = style.viewBackgroundColor
    }
}

// MARK: - UINavigationController + InjectableType

extension UINavigationController: InjectableType {
    public func setupStyling() {
        let style = container.resolveOrInjectDefault(StylingNavigationControllerStyle.self, defaultFactory: { _ in DefaultNavigationControllerStyle() })
        setup(with: style)
    }
}

// MARK: - StylingNavigationControllerStyle

public protocol StylingNavigationControllerStyle {
    var prefersLargeTitles: Bool { get }
    var largeTitleTextAttributes: [NSAttributedString.Key: Any]? { get }
    var titleTextAttributes: [NSAttributedString.Key: Any]? { get }
    var tintColor: UIColor { get }
    var viewBackgroundColor: UIColor { get }
    var backgroundImage: UIImage? { get }
    var shadowImage: UIImage? { get }
    var isTranslucent: Bool { get }
}

public extension StylingNavigationControllerStyle {
    var prefersLargeTitles: Bool { true }

    var largeTitleTextAttributes: [NSAttributedString.Key: Any]? {
        [.foregroundColor: UIColor.foregroundPrimary, .font: UIFont.stylingFont(.bold, with: 30)]
    }

    var titleTextAttributes: [NSAttributedString.Key: Any]? {
        [.foregroundColor: UIColor.foregroundPrimary, .font: UIFont.stylingFont(.bold, with: 16)]
    }

    var tintColor: UIColor { .actionPrimary }

    var viewBackgroundColor: UIColor { .clear }

    var backgroundImage: UIImage? {
        return UIImage(named: "navBarBackground", in: .module, compatibleWith: nil)
    }

    var shadowImage: UIImage? {
        return UIImage()
    }

    var isTranslucent: Bool { true }
}

// MARK: - DefaultNavigationControllerStyle

class DefaultNavigationControllerStyle: StylingNavigationControllerStyle {}
