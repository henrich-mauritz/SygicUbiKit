import Foundation
import UIKit

public class CopyableLabel: UILabel {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureCopyable()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCopyable() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CopyableLabel.showCopyMenu)))
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CopyableLabel.showCopyMenu)))
    }

    override public func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }

    @objc private func showCopyMenu() {
        guard !UIMenuController.shared.isMenuVisible else { return }
        becomeFirstResponder()
        UIMenuController.shared.setTargetRect(frame, in: superview ?? self)
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }

    override public var canBecomeFirstResponder: Bool {
        if let code = text, !code.isEmpty {
            return true
        }
        return false
    }

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
          return action == #selector(UIResponderStandardEditActions.copy)
      }
}
