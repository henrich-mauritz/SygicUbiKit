import SceneKit
import UIKit

/// This is the shape that gets drawin from botton of screen up to where the trailing car is
class TailingShape: SCNShape {
    class func shape() -> TailingShape {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -1, y: -1))
        path.addLine(to: CGPoint(x: 1, y: -1))
        path.addLine(to: CGPoint(x: 0.8, y: 1))
        path.addLine(to: CGPoint(x: -0.8, y: 1))
        path.addLine(to: CGPoint(x: -1, y: -1))
        path.close()
        let trialing = TailingShape(path: path, extrusionDepth: 0)
        return trialing
    }
}
