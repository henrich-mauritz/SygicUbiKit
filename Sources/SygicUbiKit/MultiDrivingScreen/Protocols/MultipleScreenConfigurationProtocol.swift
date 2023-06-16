import Foundation
import UIKit

// MARK: - MultiScreenBehavioralProtocol

public protocol MultiScreenBehavioralProtocol where Self: UIViewController {
    var pageControlIcon: UIImage { get }
    func multiSceenControllerShouldSwipe(_: MultipleDrivingScreenViewController) -> Bool
    func pageControlDidHide(value: Bool)
    func vehicleProfileDidUpdate()
}

public extension MultiScreenBehavioralProtocol {
    func pageControlDidHide(value: Bool) {}
}
