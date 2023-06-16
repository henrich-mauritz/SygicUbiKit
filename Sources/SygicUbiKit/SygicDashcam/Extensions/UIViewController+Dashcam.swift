import UIKit

extension UIViewController {
    func add(_ child: UIViewController?) {
        guard let child = child else { return assertionFailure() }

        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else { return }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
