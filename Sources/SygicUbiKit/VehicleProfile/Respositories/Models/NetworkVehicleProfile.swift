import Foundation
import UIKit

// MARK: - VehicleProfileDataType

public protocol VehicleProfileDataType {
    var vehicles: [NetworkVehicle] { get }
    func add(vehicle: NetworkVehicle)
}

// MARK: - NetworkVehicleProfile

public class NetworkVehicleProfile: Codable, VehicleProfileDataType {
    public class Container: Codable {
        public var vehicles: [NetworkVehicle]
    }

    public var data: Container
    public var vehicles: [NetworkVehicle] { data.vehicles }
    public func add(vehicle: NetworkVehicle) {
        data.vehicles.append(vehicle)
    }
}

// MARK: - VehicleState

public enum VehicleState: String, Codable {
    case active
    case inactive
}

// MARK: - NetworkVehicle

public class NetworkVehicle: Codable, VehicleProfileType {
    struct VehiclePostData: Codable {
        struct Container: Codable {
            var name: String
            var vehicleType: ConfigurationVehicleType
            var state: VehicleState
        }

        var vehicle: Container
        init(name: String, vehicleType: ConfigurationVehicleType, state: VehicleState) {
            vehicle = Container(name: name, vehicleType: vehicleType, state: state)
        }
    }

    struct VehiclePatchData: Codable {
        var name: String
        var state: VehicleState
    }

    public var name: String
    public var vehicleType: ConfigurationVehicleType
    public var state: VehicleState
    public var publicId: String
    public var isSelectedForDriving: Bool? = false
    init(name: String, type: VehicleType, state: VehicleState, id: String = "") {
        self.name = name
        self.vehicleType = type
        self.state = state
        self.publicId = id
    }

    convenience init(postDataResonse: NetworkPostResponseVechileData) {
        self.init(name: postDataResonse.data.name,
                  type: postDataResonse.data.vehicleType,
                  state: postDataResonse.data.state,
                  id: postDataResonse.data.publicId)
    }

    func postData() -> VehiclePostData {
        return VehiclePostData(name: name, vehicleType: vehicleType, state: state)
    }

    func patchData() -> VehiclePatchData {
        return VehiclePatchData(name: name, state: state)
    }
}

// MARK: - NetworkPostResponseVechileData

/// This classs is used only to parse the response from a put operation
public struct NetworkPostResponseVechileData: Codable {
    public struct Container: Codable {
        public var name: String
        public var vehicleType: ConfigurationVehicleType
        public var state: VehicleState
        public var publicId: String
    }

    public var data: Container
}

// MARK: - VehicleProfileConfiguration

/// This is a wrapper of the main Configuraiton, containing only the relevant information for vehicle profile, due that main configuraiton has as well driving config values
public class VehicleProfileConfiguration: Codable {
    public var maxCountPerUser: Int?
    public var configsPerType: [VehicleTypeConfiguration] = []

    init() {
        ConfigurationModule.fetchConfiguration {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(config):
                self.maxCountPerUser = config.maxTotalVehicleCountPerUser ?? 10
                self.configsPerType = config.vehicleConfigurations.map {
                    let vehicleConfig = VehicleTypeConfiguration(vehicleType: $0.vehicleType, offSeason: $0.offSeason, maxCountPerUser: $0.maxVehicleCountPerUser)
                    return vehicleConfig
                }
            case .failure(_):
                print("Something went wrong fetching the configuratino")
            }
        }
    }
}

public extension VehicleType {
    var localizedName: String {
        switch self {
        case .car:
            return "vehicleProfile.addVehicle1.typeCar".localized
        case .motorcycle:
            return "vehicleProfile.addVehicle1.typeMoto".localized
        case .camper:
            return "vehicleProfile.addVehicle1.typeCamper".localized
        case .unknown:
            return "unknown"
        }
    }

    var icon: UIImage? {
        switch self {
        case .car:
            return UIImage(named: "iconsCar", in: .module, compatibleWith: nil)
        case .motorcycle:
            return UIImage(named: "iconsMotorbike", in: .module, compatibleWith: nil)
        case .camper:
            return UIImage(named: "iconsCamper", in: .module, compatibleWith: nil)
        case .unknown:
            return nil
        }
    }
}

// MARK: - VehicleTypeConfiguration

public struct VehicleTypeConfiguration: Codable {
    public var vehicleType: VehicleType
    public var offSeason: [Int]
    public var maxCountPerUser: Int?
}
