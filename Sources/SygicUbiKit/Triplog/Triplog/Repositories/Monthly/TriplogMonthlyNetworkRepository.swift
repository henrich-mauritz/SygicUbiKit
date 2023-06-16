import Foundation

struct TriplogMonthlyNetworkRepository: TriplogMonthlyNewtworkRepositoryType {
    func fetchMonthlyData(with requestData: ApiRouterTriplog.TripsRequestData, completion: @escaping (Result<TriplogTripsDataType, Error>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterTriplog.triplogTrips(requestData)) { (result: Result<NetworkTripsData, Error>) in
            switch result {
            case let .success(tripsData):
                completion(.success(tripsData))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
