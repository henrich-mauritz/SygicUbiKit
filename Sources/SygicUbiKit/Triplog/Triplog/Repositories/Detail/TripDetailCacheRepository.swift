import Foundation

class TripDetailCacheRepository: TripDetailCacheRepositoryType {
    func fetchTripDetail(with id: String, completion: @escaping (Result<TripDetailDataProtocol, Error>) -> ()) {}

    func purgeCache(from tripId: String?) {}
}
