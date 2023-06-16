import Foundation
import UIKit

protocol VPVehicleSelectorType where Self: UIView {
    var imageIcon: UIImage? { get set }
    var vehicleName: String? { get set }
    var hasChevrom: Bool { set get }
    func configureForPlainStyle(with arrowPositon: VPBubbleVehicleSelectorView.ArrowPostion)
}
