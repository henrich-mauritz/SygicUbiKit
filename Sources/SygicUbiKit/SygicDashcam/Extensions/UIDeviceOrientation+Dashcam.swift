import AVFoundation
import UIKit

extension UIDeviceOrientation {
    func orientationForAVCapture() -> AVCaptureVideoOrientation {
        switch self {
        // UIDevice orientation is opposite to UIInterface orientation in landscape
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
}

extension AVCaptureVideoOrientation {
    var isLandscape: Bool {
        return self == .landscapeLeft || self == .landscapeRight
    }

    var interfaceOrientationMask: UIInterfaceOrientationMask {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        @unknown default:
            return .all
        }
    }
}
