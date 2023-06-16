import Foundation

public protocol VehicleProfileType: AnyObject {
    var name: String { get set }
    var vehicleType: ConfigurationVehicleType { get set }
    var state: VehicleState { get set }
    var publicId: String { get }
    var isSelectedForDriving: Bool? { get set }
}
