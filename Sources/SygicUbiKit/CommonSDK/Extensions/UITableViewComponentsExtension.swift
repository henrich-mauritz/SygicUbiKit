import Foundation
import UIKit

public extension UITableViewCell {
    class var identifier: String {
        return String(describing: self)
    }

    var margin: CGFloat { Styling.cellLayoutMargin }
}

public extension UITableViewHeaderFooterView {
    class var identifier: String {
        return String(describing: self)
    }
}
