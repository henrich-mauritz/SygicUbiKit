import Foundation
import UIKit

// MARK: - ReloadableViewController

public protocol ReloadableViewController where Self: UIViewController {
    func reloadViewData()
}

// MARK: - UINavigationController + ReloadableViewController

extension UINavigationController: ReloadableViewController {
    public func reloadViewData() {
        guard let reloadable = children.last as? ReloadableViewController else { return }
        reloadable.reloadViewData()
    }
}
