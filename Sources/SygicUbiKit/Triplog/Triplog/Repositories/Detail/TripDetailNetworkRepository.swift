import Foundation

public struct TripDetailNetworkRepository: TripDetailNetworkRepositoryType {
    let networkManager: NetworkManager = NetworkManager.shared

    public func fetchTripDetail(with id: String, completion: @escaping (Result<TripDetailDataProtocol, Error>) -> ()) {
        networkManager.requestAPI(ApiRouterTriplog.triplogTripDetail(id)) { (result: Result<NetworkTripData, Error>) in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func purgeCache(from tripId: String?) { /** does nothing **/ }
}
