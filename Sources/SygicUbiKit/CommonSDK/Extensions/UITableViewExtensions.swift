import Foundation
import UIKit

public extension UITableView {
    func register<T: UITableViewCell>(nib type: T.Type, inBundle bundle: Bundle? = nil) {
        let identifier = String(describing: type.self)
        register(
            UINib(nibName: identifier, bundle: bundle),
            forCellReuseIdentifier: identifier
        )
    }
}

public extension UITableView {
    static let defaultHeaderFooterIdentifier = "Header"

    func register<T: UITableViewHeaderFooterView>(nib type: T.Type, withIdentifier identifier: String = UITableView.defaultHeaderFooterIdentifier, inBundle bundle: Bundle? = nil)
    {
        let identifier = String(describing: type.self)
        register(
            UINib(nibName: identifier, bundle: bundle),
            forCellReuseIdentifier: identifier
        )
    }
}

public extension UITableView {
    subscript<T: UITableViewCell>(type: T.Type, indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: type.self)
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }

    subscript<T: UITableViewCell>(indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }

    subscript<T: UITableViewCell>(indexPath: IndexPath, withIdentifier identifier: String) -> T {
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
}

public extension UITableView {
    func layoutTableHeaderView() {
        guard let headerView = self.tableHeaderView else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let headerWidth = headerView.bounds.size.width

        let temporaryWidthConstraints = headerView.widthAnchor.constraint(equalToConstant: headerWidth)
            //NSLayoutConstraint.constraints(withVisualFormat: "[headerView(width)]", options: NSLayoutConstraint.FormatOptions(rawValue: UInt(0)), metrics: ["width": headerWidth], views: ["headerView": headerView])

        headerView.addConstraints([temporaryWidthConstraints])

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = headerSize.height
        var frame = headerView.frame

        frame.size.height = height
        headerView.frame = frame

        self.tableHeaderView = headerView

        headerView.removeConstraints([temporaryWidthConstraints])
        headerView.translatesAutoresizingMaskIntoConstraints = true
    }
}
