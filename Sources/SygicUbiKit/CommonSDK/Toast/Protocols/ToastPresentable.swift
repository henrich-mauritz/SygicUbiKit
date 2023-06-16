import Foundation
import UIKit

public protocol ToastPresentable {
    var title: String { get set }
    var icon: UIImage? { get set }
}
