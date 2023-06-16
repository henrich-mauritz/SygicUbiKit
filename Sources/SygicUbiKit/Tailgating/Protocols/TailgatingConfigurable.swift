import Foundation
import UIKit

// MARK: - TailgatingConfigurable

public protocol TailgatingConfigurable {
    var tailgatingEvent: TailgatingEventType { get set }

    /// The color couple for the close position
    var closeColor: TailgatingGradientable { get set }

    /// The color for the far position
    var farColor: TailgatingGradientable { get set }

    /// The sliding image, this normally is an arrow
    var slidingImage: UIImage? { get }

    /// Distance to object from 1 to 5 where 1 is the closes and 5 is the further
    var worldDistance: Double { get }

    /// set if the object is too close or still is in ok range
    var isTooClose: Bool { get }

    var pitchCamera: Bool { get }

    var animateTransitions: Bool { get }
}

// MARK: - TailgatingGradientable

public protocol TailgatingGradientable {
    var beginColor: UIColor { get set }
    var endColor: UIColor { get set }
}

public extension TailgatingConfigurable {
    var pitchCamera: Bool { return true }
    var slidingImage: UIImage? { return UIImage(named: "arrow", in: .module, compatibleWith: nil) }
    var worldDistance: Double { return log(tailgatingEvent.carDistance) + 0.5 }
    var isTooClose: Bool { return tailgatingEvent.isTooClose }
    var animateTransitions: Bool { return true }
}

// MARK: - TailgatingEventType

public protocol TailgatingEventType {
    var carFrame: CGRect { get set }
    var carDistance: Double { get set }
    var timeToImpact: Double { get set }
    var isTooClose: Bool { get set }
}
