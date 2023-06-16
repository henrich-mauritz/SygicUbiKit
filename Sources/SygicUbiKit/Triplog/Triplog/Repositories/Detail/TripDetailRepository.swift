
import Foundation

class TripDetailRepository: TripDetailRepositoryType {
    let networkRepository: TripDetailNetworkRepositoryType
    let cacheRepository: TripDetailCacheRepositoryType

    init(networkRepo: TripDetailNetworkRepositoryType, cacheRepo: TripDetailCacheRepositoryType) {
        self.networkRepository = networkRepo
        self.cacheRepository = cacheRepo
    }

    func fetchTripDetail(with id: String, completion: @escaping (Result<TripDetailDataProtocol, Error>) -> ()) {
        //To analyze: Check if we would like to add cache to this functionality or no
        //for now it will do network calls alwasy.
        networkRepository.fetchTripDetail(with: id, completion: completion)
    }

    func purgeCache(from tripId: String?) {
        self.cacheRepository.purgeCache(from: tripId)
    }
}
