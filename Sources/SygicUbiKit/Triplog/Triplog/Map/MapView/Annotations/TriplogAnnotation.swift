import MapKit
import UIKit

// MARK: - TriplogAnnotation

public class TriplogAnnotation: NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    public var iconColor: UIColor = .actionPrimary
    public var fillColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    public var annotationType: EventPinType = .end
    public var animate: Bool = false
    public var priority: MKFeatureDisplayPriority = MKFeatureDisplayPriority(rawValue: 1)

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

// MARK: - TriplogReportAnnotation

public class TriplogReportAnnotation: NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    public var color: UIColor = SevernityLevel.one.toColor()
    public var speed: Int = 0

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

// MARK: - TriplogEventAnnotation

public class TriplogEventAnnotation: TriplogAnnotation {
    public var event: TripDetailEvent
    public var eventType: EventType

    public init(eventData: TripDetailEvent, type: EventType) {
        self.event = eventData
        self.eventType = type
        super.init(coordinate: eventData.coordinates.first ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
        iconColor = type.eventColor()
        priority = MKFeatureDisplayPriority(rawValue: MKFeatureDisplayPriority.required.rawValue + type.eventPriority())
    }
}
