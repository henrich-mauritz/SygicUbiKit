import Foundation

struct TriplogOverviewNetworkRepository: TriplogOverviewNetworkRepositoryType {
    func fetch(overviewWith archiveId: String?, vehicleID: String? = nil, _ completion: @escaping (Result<TriplogOverviewDataType, Error>) -> ()) {
        if let id = archiveId {
            NetworkManager.shared.requestAPI(ApiRouterTriplog.triplogPeriodOverView(id, vehicleId: vehicleID)) {(result: Result<NetworkOverviewData, Error>) in
                switch result {
                case let .success(data):
                    completion(.success(data))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } else {
            NetworkManager.shared.requestAPI(ApiRouterTriplog.triplogCurrentPeriod(vehicleID)) { (result: Result<NetworkOverviewData, Error>) in
                switch result {
                case let .success(data):
                    completion(.success(data))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
}
