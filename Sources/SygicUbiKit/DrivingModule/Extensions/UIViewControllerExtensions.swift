import UIKit

extension UIViewController {
    func roundedCorners(radius: CGFloat, topOffset: CGFloat, corners: UIRectCorner...) {
        //calculate by how much the frame needs to be lowered to look like on iOS 13
        let rect = topOffset == 0 ? view.frame : CGRect(x: 0, y: view.drivingModalViewTopOffset, width: view.frame.width, height: view.frame.height)
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: radius,
                                                    height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
    }

    func roundedTopCorners(radius: CGFloat) {
        roundedCorners(radius: radius, topOffset: view.drivingModalViewTopOffset, corners: .topLeft, .topRight)
    }

    func resetRoundedCorners() {
        view.layer.mask = nil
    }
}

extension UIView {
    var drivingModalViewTopOffset: CGFloat {
        return 0
    }
}
