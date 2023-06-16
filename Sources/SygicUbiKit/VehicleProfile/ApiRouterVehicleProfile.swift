import Foundation

public enum ApiRouterVehicleProfile: ApiEndpoints {
    case listVehicles
    case createVehicle
    case updateVehicle(_ id: String)

    public var endpoint: String {
        switch self {
        case .listVehicles, .createVehicle:
            return "profiles/vehicles"
        case let .updateVehicle(id):
            return "profiles/vehicles/\(id)"
        }
    }

    public var requestMethod: String {
        switch self {
        case .listVehicles:
            return "GET"
        case .createVehicle:
            return "POST"
        case .updateVehicle(_):
            return "PATCH"
        }
    }

    public var version: Int {
        return 3
    }
}
