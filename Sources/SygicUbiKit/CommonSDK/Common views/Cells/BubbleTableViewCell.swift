import Foundation
import UIKit

open class BubbleTableViewCell: UITableViewCell {
    public lazy var bubbleContainerView: UIView = {
        let view = UIView(frame: contentView.bounds)
        view.backgroundColor = bubbleBackgroundColor
        view.layer.cornerRadius = Styling.cornerRadiusModalPopup
        return view
    }()

    public var bubbleCornerRadius: CGFloat = Styling.cornerRadiusModalPopup {
        willSet {
            bubbleContainerView.layer.cornerRadius = newValue
        }
    }

    public var bubbleBackgroundColor: UIColor = .backgroundSecondary {
        willSet {
            bubbleContainerView.backgroundColor = newValue
        }
    }

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 320, height: 75) // putting some value to set some initial height
        setupBubbleLayout()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBubbleLayout()
    }

    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard selectionStyle != .none else { return }
        if animated {
            let animationCurve: UIView.AnimationOptions = highlighted ? .curveEaseIn : .curveEaseOut
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, animationCurve]) {
                self.updateBubbleBackgroundColor(highlighted)
            }
        } else {
            if highlighted {
                updateBubbleBackgroundColor(true)
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in // fast taps cancel highlight too fast to notice
                    guard let self = self, !self.isHighlighted else { return }
                    self.updateBubbleBackgroundColor(false)
                }
            }
        }
    }

    private func updateBubbleBackgroundColor(_ highlighted: Bool) {
        if highlighted {
            bubbleContainerView.backgroundColor = bubbleBackgroundColor.withAlphaComponent(Styling.highlightedStateAlpha)
        } else {
            bubbleContainerView.backgroundColor = bubbleBackgroundColor
        }
    }

    private func setupBubbleLayout() {
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        contentView.cover(with: bubbleContainerView, insets: NSDirectionalEdgeInsets(top: margin, leading: margin, bottom: margin, trailing: margin))
    }
}
