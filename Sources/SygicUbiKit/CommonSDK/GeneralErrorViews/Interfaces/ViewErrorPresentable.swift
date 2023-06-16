import Foundation
import UIKit

// MARK: - UIViewController + ViewErrorPresentable

extension UIViewController: ViewErrorPresentable {
    /// Presents the error View based on the viewModel provided. If the view is a table view class, it will set the message view as its background
    /// Also if the view is not a table view it will add the error view on lever 0, meaning you have to make sure above views are transparent
    /// - Parameters:
    ///   - viewModel: MessageViewModelType
    ///   - view: nulifiable
    public func presentErrorView(with viewModel: MessageViewModelType, in view: UIView? = nil) {
        var parentView: UIView
        if let view = view {
            parentView = view
        } else {
            parentView = self.view
        }

        let messageView = MessageView(frame: .zero)
        messageView.viewModel = viewModel
        messageView.tag = 9999
        if let parentView = parentView as? UIScrollView {
            if let tableView = parentView as? UITableView {
                tableView.backgroundView = messageView
            } else if let collectionView = parentView as? UICollectionView {
                collectionView.backgroundView = messageView
            }
            parentView.layoutIfNeeded()
        } else {
            messageView.translatesAutoresizingMaskIntoConstraints = false
            if parentView.viewWithTag(9999) == nil { //making sure was not added before already
                parentView.cover(with: messageView, insets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                parentView.sendSubviewToBack(messageView)
            }
        }
    }

    /// Dismiss the message view perviously added if any
    /// - Parameter view: nulifiable
    public func dismissErrorView(from view: UIView? = nil) {
        var parentView: UIView
        if let view = view {
            parentView = view
        } else {
            parentView = self.view
        }
        if let parentView = parentView as? UIScrollView {
            if let tableView = parentView as? UITableView, let _ = tableView.backgroundView as? MessageView {
                tableView.backgroundView = nil
            } else if let collectionView = parentView as? UICollectionView, let _ = collectionView.backgroundView as? MessageView {
                collectionView.backgroundView = nil
            }
        } else if let messageView = parentView.viewWithTag(9999) as? MessageView { //jsut making sure its message view
            messageView.removeFromSuperview()
        }
    }
}

// MARK: - ViewErrorPresentable

public protocol ViewErrorPresentable {
    func presentErrorView(with viewModel: MessageViewModelType, in view: UIView?)
    func dismissErrorView(from view: UIView?)
}

extension ViewErrorPresentable {
    func presentErrorView(with viewModel: MessageViewModelType, in view: UIView?) {}
    func dismissErrorView(from view: UIView?) {}
}
