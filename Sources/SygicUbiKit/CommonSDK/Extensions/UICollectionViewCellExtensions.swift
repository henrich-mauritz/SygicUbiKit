import Foundation
import UIKit

public extension UICollectionViewCell {
    class var cellIdentifier: String {
        return String(describing: self)
    }
}
