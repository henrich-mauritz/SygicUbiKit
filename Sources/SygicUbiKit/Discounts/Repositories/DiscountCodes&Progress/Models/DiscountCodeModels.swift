import Foundation

// MARK: - NetworkDiscountCodesData

public struct NetworkDiscountCodesData: Codable, DiscountCodesDataProtocol {
    struct ContainerData: Codable {
        struct DiscountCodesData: Codable {
            var page: Int
            var pageSize: Int
            var pagesCount: Int
            var totalItemsCount: Int
            var items: [NetworkDiscountCodeData]
        }

        var discounts: DiscountCodesData
    }

    var data: ContainerData
}

// MARK: DiscountCodesDataProtocol

public extension NetworkDiscountCodesData {
    var page: Int { data.discounts.page }
    var pageSize: Int { data.discounts.pageSize }
    var pagesCount: Int { data.discounts.pagesCount }
    var totalItemsCount: Int { data.discounts.totalItemsCount }
    var items: [DiscountCode] { data.discounts.items }
}

// MARK: - NetworkDiscountCodeData

struct NetworkDiscountCodeData: Codable, DiscountCode {
    struct Usage: Codable {
        var usedAt: Date?
        var usedOnInsurancePolicy: String?
    }

    var discountCode: String
    var validUntil: Date
    var discountAmount: Double
    var discountUsage: Usage?
    var state: DiscountCodeState
    var usedAt: Date? { discountUsage?.usedAt }
    var insurancePolicy: String? { discountUsage?.usedOnInsurancePolicy }
}

// MARK: - DiscountCodeState

public enum DiscountCodeState: String, Codable {
    case available
    case used
    case reversed
    case expired
}
