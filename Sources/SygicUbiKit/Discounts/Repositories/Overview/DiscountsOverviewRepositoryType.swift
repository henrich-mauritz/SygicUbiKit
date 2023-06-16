import Foundation

// MARK: - DiscountsOverviewRepositoryType

public protocol DiscountsOverviewRepositoryType {
    func loadDiscounts(for vehicleId: String, _ completion: @escaping (Result<DiscountsOverviewProtocol, Error>) -> ())
    func claimDiscounts(for vehicleId: String, _ completion: @escaping (Result<DiscountProtocol, Error>) -> ())
}

// MARK: - DiscountsOverviewNetworkRepositoryType

public protocol DiscountsOverviewNetworkRepositoryType: DiscountsOverviewRepositoryType {}
