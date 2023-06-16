import MapKit
import UIKit

public class TriplogPolyline: MKPolyline {
    public var lineColor: UIColor = .mapRoute
    public var stroke: CGFloat = 5
    public var event: TripDetailEvent?
    public var eventType: EventType?
}
