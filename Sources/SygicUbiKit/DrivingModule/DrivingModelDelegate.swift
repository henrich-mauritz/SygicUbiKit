import Foundation
import Driving

// MARK: - DrivingModelDelegate

public protocol DrivingModelDelegate: AnyObject {
    var inTrip: Bool { get }
    func drivingDataUpdated()
    func drivingManager(_ drivingManager: DrivingManager, didEncounter error: Error)
    func drivingManagerDidStartTrip(_ drivingManager: DrivingManager)
    func drivingManager(_ drivingManager: DrivingManager, didEndTrip trip: SygicDrivingTrip?)

    /// Delegated message about Trip upload result
    /// - Parameters:
    ///   - drivingManager: DrivingManager
    ///   - tripId: Uploaded trip ID (nil if error occures)
    ///   - success: Server status if trip was received successfuly
    ///   - errorStatus: Server response error status
    func drivingDataTripEnded(_ drivingManager: DrivingManager, tripId: String?, success: Bool, errorStatus: SygicTripUploadError)
    func driving(_ drivingManager: DrivingManager, tripDiscartedWith reason: SygicTripDiscartedReason)
}

public extension DrivingModelDelegate {
    var inTrip: Bool { DrivingManager.shared.driving }
    // empty implementation
    func drivingManagerDidStartTrip(_ drivingManager: DrivingManager) {}
    func drivingManager(_ drivingManager: DrivingManager, didEndTrip trip: SygicDrivingTrip?) {}
    func drivingDataTripEnded(_ drivingManager: DrivingManager, tripId: String?, success: Bool, errorStatus: SygicTripUploadError) {}
    func driving(_ drivingManager: DrivingManager, tripDiscartedWith reason: SygicTripDiscartedReason) {}
}
