import AVFoundation
import Foundation

extension CMVideoDimensions {
    func resolution(for orientation: AVCaptureVideoOrientation) -> CGSize {
        if orientation.isLandscape {
            return CGSize(width: CGFloat(width), height: CGFloat(height))
        } else {
            return CGSize(width: CGFloat(height), height: CGFloat(width))
        }
    }
}
