import Foundation

struct DiscountsOverviewNetworkRepository: DiscountsOverviewNetworkRepositoryType {
    func loadDiscounts(for vehicleId: String, _ completion: @escaping (Result<DiscountsOverviewProtocol, Error>) -> ()) {
        let networking = NetworkManager.shared
        networking.requestAPI(ApiRouterDiscounts.endpointDiscounts(vehicleId)) { (result: Result<NetworkDiscounts, Error>) in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func claimDiscounts(for vehicleId: String, _ completion: @escaping (Result<DiscountProtocol, Error>) -> ()) {
        let networking = NetworkManager.shared
        networking.requestAPI(ApiRouterDiscounts.endpointClaimDiscount(vehicleId)) { (result: Result<NetworkClaimData, Error>) in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
