import Foundation
import UIKit

// MARK: - SYTabBarContentController

public protocol SYTabBarContentController where Self: UIViewController {
    var notificationAvailable: Bool { get }
}

// MARK: - SYTabBarItem

public protocol SYTabBarItem: UIControl {
    var contentViewController: UIViewController? { get }
    var highlightingAnchorView: UIView { get }
    var iconSize: CGSize { get }
    init(with icon: UIImage, iconSize: CGSize, contentController: UIViewController?)
    func showNotificationBadge(_ show: Bool)
}

// MARK: - SYTabBarItemView

public class SYTabBarItemView: UIControl, SYTabBarItem {
    public var contentViewController: UIViewController?
    public var color: UIColor = .foregroundPrimary
    public var selectedColor: UIColor = .foregroundPrimary

    private var showNotificationBadge: Bool = false {
        didSet {
            updateBadge()
        }
    }

    public var highlightingAnchorView: UIView {
        iconImageView
    }

    override public var isSelected: Bool {
        didSet {
            updateBadge()
            guard color != selectedColor else { return }
            if isSelected {
                iconImageView.tintColor = selectedColor
            } else {
                iconImageView.tintColor = color
            }
        }
    }

    public let iconSize: CGSize
    public let badgeSize: CGFloat = NotificationDotView.dotSize

    private let iconImageView = UIImageView()

    private lazy var badgeView: UIView = {
        let view = NotificationDotView()
        view.isHidden = true
        view.widthAnchor.constraint(equalToConstant: badgeSize).isActive = true
        view.heightAnchor.constraint(equalToConstant: badgeSize).isActive = true
        return view
    }()

    public required init(with icon: UIImage, iconSize: CGSize = CGSize(width: 22, height: 22), contentController: UIViewController? = nil) {
        self.iconSize = iconSize
        super.init(frame: .zero)
        contentViewController = contentController
        iconImageView.contentMode = .center
        iconImageView.image = icon
        iconImageView.tintColor = color
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func showNotificationBadge(_ show: Bool) {
        showNotificationBadge = show
    }

    private func setupLayout() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        addSubview(badgeView)
        var constraints = [NSLayoutConstraint]()

        constraints.append(iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(iconImageView.heightAnchor.constraint(equalToConstant: iconSize.height))
        constraints.append(iconImageView.widthAnchor.constraint(equalToConstant: iconSize.width))

        constraints.append(badgeView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: iconSize.width / 2.0))
        constraints.append(badgeView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -iconSize.height / 2.0))
        constraints.append(badgeView.heightAnchor.constraint(equalToConstant: badgeSize))
        constraints.append(badgeView.widthAnchor.constraint(equalTo: badgeView.heightAnchor))

        NSLayoutConstraint.activate(constraints)
    }

    private func updateBadge() {
        badgeView.isHidden = !showNotificationBadge || isSelected
    }
}
