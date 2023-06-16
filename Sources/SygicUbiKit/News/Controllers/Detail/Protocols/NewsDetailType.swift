import Foundation
import UIKit

public protocol NewsDetailType: NewsInfoItemType {
    var videoIdentifier: String? { get set }
    var image: UIImage? { get set }
    var attString: NSMutableAttributedString? { get set }
}
