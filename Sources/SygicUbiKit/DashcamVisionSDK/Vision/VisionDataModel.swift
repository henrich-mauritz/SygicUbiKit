import Foundation
import VisionLib

extension SYVisionSignType {
    var speedLimit: Double? {
        switch self {
        case .maximumspeedlimit10:
            return 10
        case .maximumspeedlimit20:
            return 20
        case .maximumspeedlimit30:
            return 30
        case .maximumspeedlimit40:
            return 40
        case .maximumspeedlimit50:
            return 50
        case .maximumspeedlimit60:
            return 60
        case .maximumspeedlimit70:
            return 70
        case .maximumspeedlimit80:
            return 80
        case .maximumspeedlimit90:
            return 90
        case .maximumspeedlimit100:
            return 100
        case .maximumspeedlimit110:
            return 110
        case .maximumspeedlimit120:
            return 120
        case .maximumspeedlimit130:
            return 130
        default:
            return nil
        }
    }
}

extension SYVisionObject {
    func rect(to preview: UIView) -> CGRect {
        let x = CGFloat(min(bounds.left, bounds.right)) * preview.bounds.width
        let y = CGFloat(min(bounds.top, bounds.bottom)) * preview.bounds.height
        let xx = CGFloat(max(bounds.left, bounds.right)) * preview.bounds.width
        let yy = CGFloat(max(bounds.top, bounds.bottom)) * preview.bounds.height
        return CGRect(x: x, y: y, width: xx - x, height: yy - y)
    }

    func rect(to previewLayer: AVCaptureVideoPreviewLayer?, or drawingView: UIView) -> CGRect {
        if let preview = previewLayer {
            return transformedBounds(preview)
        }
        return rect(to: drawingView)
    }
}

extension SYLine {
    func line(on previewLayer: AVCaptureVideoPreviewLayer?, or drawingView: UIView) -> UIBezierPath {
        let canvas: CGRect = previewLayer?.bounds ?? drawingView.bounds
        let line = UIBezierPath()
        line.move(to: CGPoint(x: canvas.width * CGFloat(x1), y: canvas.height * CGFloat(y1)))
        line.addLine(to: CGPoint(x: canvas.width * CGFloat(x2), y: canvas.height * CGFloat(y2)))
        line.close()
        return line
    }
}

extension SpeedLimitSource {
    var sourceId: SourceId { Int32(rawValue) }

    var priority: Priority { 1 }

    init?(with sourceId: SourceId) {
        self.init(rawValue: Int(sourceId))
    }
}

// MARK: - VisionTailgatingThresholds

public protocol VisionTailgatingThresholds {
    /// Minimum tailgating duration to detect tailgating event
    var minDuration: TimeInterval { get }
    /// Time to impact to seen coliding object for low severity
    var low: Double { get }
    /// Time to impact to seen coliding object for high severity
    var high: Double { get }
}

public extension VisionTailgatingThresholds {
    var minDuration: TimeInterval { 2 }
    var low: Double { 1 }
    var high: Double { 0.5 }
}

// MARK: - DefaultTailgatingThresholds

struct DefaultTailgatingThresholds: VisionTailgatingThresholds {}
