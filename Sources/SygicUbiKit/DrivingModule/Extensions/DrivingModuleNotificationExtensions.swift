import Foundation

public extension Notification.Name {
    static var drivingTripPossiblyStarted: Notification.Name { Notification.Name("DrivingManagerTripPossiblyStartedNotification") }
    static var drivingTripStarted: Notification.Name { Notification.Name("DrivingManagerTripStartedNotification") }
    static var drivingTripEnded: Notification.Name { Notification.Name("DrivingManagerTripEndedNotification") }
    static var drivingTripCanceled: Notification.Name { Notification.Name("DrivingManagerTripStartCanceledNotification") }
    static var drivingWaitingForTripScore: Notification.Name { Notification.Name("DrivingManagerWaitingForTripScoreNotification") }
    static var tripSummaryNotification: Notification.Name { Notification.Name("TripSummaryNotification") }
    static var drivingTripManuallyStopNotification: Notification.Name { Notification.Name("drivingTripManuallyStopNotification") }
}
