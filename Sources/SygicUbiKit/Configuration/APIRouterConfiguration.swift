import Foundation

public enum ApiRouterConfiguration: ApiEndpoints {
    case vehicleConfigurations

    public var endpoint: String {
        switch self {
        case .vehicleConfigurations:
            return "apps/config"
        }
    }

    public var version: Int { 3 }
}
