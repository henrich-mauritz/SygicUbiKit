import Foundation

struct DiscountsOverviewRepository: DiscountsOverviewRepositoryType {
    let networkRepository: DiscountsOverviewNetworkRepositoryType

    func loadDiscounts(for vehicleId: String, _ completion: @escaping (Result<DiscountsOverviewProtocol, Error>) -> ()) {
        networkRepository.loadDiscounts(for: vehicleId, completion)
    }

    func claimDiscounts(for vehicleId: String, _ completion: @escaping (Result<DiscountProtocol, Error>) -> ()) {
        networkRepository.claimDiscounts(for: vehicleId, completion)
    }
}
