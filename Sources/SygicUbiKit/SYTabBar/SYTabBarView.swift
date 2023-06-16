import UIKit

public class SYTabBarView: UIView {
    public var tabs = [SYTabBarItem]() {
        didSet {
            for tab in oldValue {
                stackView.removeArrangedSubview(tab)
                tab.removeFromSuperview()
            }
            for tab in tabs {
                stackView.addArrangedSubview(tab)
            }
            if let tabView = tabs.first {
                moveHighlighterLeadingConstraint(to: tabView.highlightingAnchorView)
                moveHighlighterTrailingConstraint(to: tabView.highlightingAnchorView)
                highlighterHeightConstraint.constant = highlighterHeight
                highlighter.layer.cornerRadius = highlighterHeight / 2.0
                highlighter.centerYAnchor.constraint(equalTo: tabView.highlightingAnchorView.centerYAnchor).isActive = true
            }
        }
    }

    public static let tabBarHeight: CGFloat = 56

    public var height: CGFloat = tabBarHeight {
        didSet {
            heightConstraint.constant = height
        }
    }

    private lazy var highlighter: UIView = {
         let view = UIView()
        view.backgroundColor = .buttonBackgroundSecondary
        return view
    }()

    private lazy var heightConstraint: NSLayoutConstraint = {
        heightAnchor.constraint(equalToConstant: height)
    }()

    private lazy var highlighterHeightConstraint: NSLayoutConstraint = {
        highlighter.heightAnchor.constraint(equalToConstant: highlighterHeight)
    }()

    private var highlighterMargin: CGFloat {
        guard let tab = tabs.first else { return 9 }
        return (highlighterHeight - tab.iconSize.height) / 2.0
    }

    private var highlighterLeading: NSLayoutConstraint?
    private var highlighterTrailing: NSLayoutConstraint?

    private let highlighterHeight: CGFloat = 40

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        setupLayoutConstraints()
        setupHighlighterConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayoutConstraints() {
        heightConstraint.isActive = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints.append(stackView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(stackView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    private func setupHighlighterConstraints() {
        stackView.addSubview(highlighter)
        highlighter.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints.append(highlighterHeightConstraint)
        NSLayoutConstraint.activate(constraints)
    }

    public func highlightTab(_ selected: SYTabBarItem, oldSelected: SYTabBarItem) {
        guard let firstIndex = tabs.firstIndex(where: { $0 == selected }),
            let secondIndex = tabs.firstIndex(where: { $0 == oldSelected }) else { return }

        let movingRight: Bool = firstIndex > secondIndex

        let duration: TimeInterval = 0.5
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .calculationModeLinear], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                self.animateHighlighterKeyFrame1(selected.highlightingAnchorView, moveToRight: movingRight)
                self.layoutIfNeeded()
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
                self.animateHighlighterKeyFrame2(selected.highlightingAnchorView, moveToRight: movingRight)
                self.layoutIfNeeded()
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                self.highlighter.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
                self.highlighter.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.2) {
                self.highlighter.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.2) {
                self.highlighter.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                self.highlighter.transform = CGAffineTransform.identity
            }
        }, completion: nil)
    }

    private func animateHighlighterKeyFrame1(_ anchorView: UIView, moveToRight: Bool) {
        if moveToRight {
            moveHighlighterTrailingConstraint(to: anchorView)
        } else {
            moveHighlighterLeadingConstraint(to: anchorView)
        }
    }

    private func animateHighlighterKeyFrame2(_ anchorView: UIView, moveToRight: Bool) {
        if !moveToRight {
            moveHighlighterTrailingConstraint(to: anchorView)
        } else {
            moveHighlighterLeadingConstraint(to: anchorView)
        }
    }

    private func moveHighlighterLeadingConstraint(to anchorView: UIView) {
        highlighterLeading?.isActive = false
        highlighterLeading = highlighter.leadingAnchor.constraint(equalTo: anchorView.leadingAnchor, constant: -highlighterMargin)
        highlighterLeading?.isActive = true
    }

    private func moveHighlighterTrailingConstraint(to anchorView: UIView) {
        highlighterTrailing?.isActive = false
        highlighterTrailing = highlighter.trailingAnchor.constraint(equalTo: anchorView.trailingAnchor, constant: highlighterMargin)
        highlighterTrailing?.isActive = true
    }
}
