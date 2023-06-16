import Foundation
import UIKit

// MARK: - StylingButtonType

public protocol StylingButtonType {
    var titleFont: UIFont? { get set }
    var height: CGFloat { get set }
    var radius: CGFloat { get set }
    var textAlignment: NSTextAlignment { get set }
    var titleColor: UIColor { get set }
    var filled: Bool { get set }
    var stroked: Bool { get set }
    var backgroundColor: UIColor { get set }
    var strokeColor: UIColor { get set }
    var lineWidth: CGFloat { get set }
    var icon: UIImage? { get set }
}

public extension StylingButtonType {
    var icon: UIImage? { return nil }
}
