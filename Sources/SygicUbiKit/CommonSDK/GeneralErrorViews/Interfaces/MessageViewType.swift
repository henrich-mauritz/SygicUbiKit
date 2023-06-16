import Foundation
import UIKit

// MARK: - MessageViewVisual

public protocol MessageViewVisual {
    var titleFont: UIFont? { get }
    var subtitleFont: UIFont? { get }
    var titleColor: UIColor { get }
    var subtitleColor: UIColor { get }
}

public extension MessageViewVisual {
    var titleFont: UIFont? { return UIFont.stylingFont(.bold, with: 16) }
    var subtitleFont: UIFont? { return UIFont.stylingFont(.regular, with: 16) }
    var titleColor: UIColor { return .foregroundPrimary }
    var subtitleColor: UIColor { return .foregroundPrimary }
}

// MARK: - MessageViewType

public protocol MessageViewType {
    var image: UIImage? { get set }
    var title: String { get set }
    var message: String { get set }
}

public typealias MessageViewModelType = MessageViewVisual & MessageViewType
