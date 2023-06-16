import Foundation
import Driving

public class DrivingMulticastDelegate: DrivingModelDelegate {
    private let multicast = SYMultycastDelegate<DrivingModelDelegate>()

    public init() {}

    public func add(delegate: DrivingModelDelegate) {
        multicast.add(delegate)
    }

    public func remove(delegate: DrivingModelDelegate) {
        multicast.remove(delegate)
    }

    public func drivingDataUpdated() {
        multicast.invoke {$0.drivingDataUpdated()}
    }

    public func drivingManager(_ drivingManager: DrivingManager, didEncounter error: Error) {
        multicast.invoke {$0.drivingManager(drivingManager, didEncounter: error)}
    }

    public func drivingManagerDidStartTrip(_ drivingManager: DrivingManager) {
        multicast.invoke {$0.drivingManagerDidStartTrip(drivingManager)}
    }

    public func drivingManager(_ drivingManager: DrivingManager, didEndTrip trip: SygicDrivingTrip?) {
        multicast.invoke {$0.drivingManager(drivingManager, didEndTrip: trip)}
    }

    public func drivingDataTripEnded(_ drivingManager: DrivingManager, tripId: String?, success: Bool, errorStatus: SygicTripUploadError) {
        multicast.invoke { $0.drivingDataTripEnded(drivingManager, tripId: tripId, success: success, errorStatus: errorStatus) }
    }

    public func driving(_ drivingManager: DrivingManager, tripDiscartedWith reason: SygicTripDiscartedReason) {
        multicast.invoke { $0.driving(drivingManager, tripDiscartedWith: reason) }
    }
}
