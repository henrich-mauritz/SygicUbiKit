import Foundation

enum ApiRouterDiscounts: ApiEndpoints {
    public struct DiscountRequestData: Codable {
        struct Filter: Codable {
            var page: Int = 1
            var pageSize: Int = 100
            var allowExpired: Bool = true
            var isDescending: Bool = true

            mutating func setPageNumber(page: Int) {
                self.page = page
            }
        }

        var filter: Filter
    }

    case endpointDiscounts(_ vehicleId: String)
    case endpointClaimDiscount(_ vehicleId: String)
    case endpointHowToInstructions(_ vehicleType: VehicleType)
    case endpointDiscountProgress(_ vehicleId: String)
    case endpointDiscountCodes(_ vehicleId: String, filterData: DiscountRequestData)

    public var requestMethod: String {
        switch self {
        case .endpointClaimDiscount:
            return "POST"
        default:
            return "GET"
        }
    }

    public var endpoint: String {
        switch self {
        case let .endpointDiscounts(vehicleId):
            return String(format: "discount/%@/challenge-progressions/current", vehicleId)
        case let .endpointClaimDiscount(vehicleId):
            return String(format: "discount/%@/claiming", vehicleId)
        case let .endpointHowToInstructions(type):
            return String(format: "discount/terms/%@", type.rawValue)
        case let .endpointDiscountProgress(vehicleId):
            return String(format: "discount/%@/challenge-progressions", vehicleId)
        case let .endpointDiscountCodes(vehicleId, _):
            return String(format: "discount/%@/claimed-discounts", vehicleId)
        }
    }

    public var version: Int { 3 }

    func queryItems() -> [URLQueryItem]? {
        switch self {
        case let .endpointDiscountCodes(_, filterData: filterData):
            return queryItems(from: filterData.filter)
        default:
            return nil
        }
    }
}
