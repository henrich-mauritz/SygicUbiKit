import MapKit
import UIKit

// MARK: - TriplogEventAnnotationView

public class TriplogEventAnnotationView: MKAnnotationView {
    public static let reuseIndentifier: String = "SYAnotationView"

    public var color: UIColor = .mapRoute

    public var color2: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)

    public var pinType: EventPinType = .event {
        didSet {
            switch pinType {
            case .start:
                frame = CGRect(x: 0, y: 0, width: 16, height: 16)
                centerOffset = .zero
            case .end:
                frame = CGRect(x: 0, y: 0, width: 24, height: 32)
                centerOffset = CGPoint(x: 4, y: -10)
            case .event:
                frame = CGRect(x: 0, y: 0, width: 18, height: 18)
                centerOffset = .zero
            }
            setNeedsDisplay()
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = nil
        backgroundColor = .clear
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        image = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func draw(_ rect: CGRect) {
        //// Color Declarations
        let fillColor = color
        if pinType == .start {
            let ovalPath = UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: 12, height: 12))
            fillColor.setFill()
            ovalPath.fill()
        } else if pinType == .end {
            let ovalPath = UIBezierPath(ovalIn: CGRect(x: 2, y: 18, width: 12, height: 12))
            fillColor.setFill()
            ovalPath.fill()
            let flagImage = UIImage(named: "pinFinish", in: .module, compatibleWith: nil)
            flagImage?.draw(at: CGPoint(x: 6, y: 0))
        } else {
            drawPin()
        }
    }

    func drawPin() {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        //// Color Declarations
        let fillColor = color
        //// Group 3
        context.saveGState()
        //// Bezier Drawing
        let bezierPath = UIBezierPath(ovalIn: bounds)
        fillColor.setFill()
        bezierPath.fill()
        ////Cleaning
        context.restoreGState()
    }

    /// Override the layer factory for this class to return a custom CALayer class
    override public class var layerClass: AnyClass {
        return ZPositionableLayer.self
    }

    /// convenience accessor for setting zPosition
    public var priorityZPosition: CGFloat {
        get {
            return (self.layer as! ZPositionableLayer).stickyZPosition
        }
        set {
            (self.layer as! ZPositionableLayer).stickyZPosition = newValue
        }
    }
}

// MARK: - EventPinType

public enum EventPinType {
    case start, end, event
}

// MARK: - ZPositionableLayer

/// iOS 11 automagically manages the CALayer zPosition, which breaks manual z-ordering.
/// This subclass just throws away any values which the OS sets for zPosition, and provides
/// a specialized accessor for setting the zPosition
private class ZPositionableLayer: CALayer {
    /// no-op accessor for setting the zPosition
    override var zPosition: CGFloat {
        get {
            return super.zPosition
        }
        set {
            // do nothing
        }
    }

    /// specialized accessor for setting the zPosition
    var stickyZPosition: CGFloat {
        get {
            return super.zPosition
        }
        set {
            super.zPosition = newValue
        }
    }
}
