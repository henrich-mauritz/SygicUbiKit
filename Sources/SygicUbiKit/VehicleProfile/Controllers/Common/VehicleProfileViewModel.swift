import Foundation
import UIKit

open class VehicleProfileViewModel {
    var vehicle: NetworkVehicle

    var name: String {
        set {
            vehicle.name = newValue
        }
        get {
            vehicle.name
        }
    }

    var state: VehicleState {
        get {
            return vehicle.state
        }
        set {
            vehicle.state = newValue
        }
    }

    var icon: UIImage? {
        return vehicle.vehicleType.icon
    }

    init(with vehicle: NetworkVehicle) {
        self.vehicle = vehicle
    }
}
