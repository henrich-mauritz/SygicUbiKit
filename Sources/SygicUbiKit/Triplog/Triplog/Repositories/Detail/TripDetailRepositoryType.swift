import Foundation

// MARK: - TripDetailRepositoryType

public protocol TripDetailRepositoryType {
    func fetchTripDetail(with id: String, completion: @escaping (Result<TripDetailDataProtocol, Error>) -> ())
    /// Purge the cache
    /// - Parameter tripId: if nil it purgues the whole cache
    func purgeCache(from tripId: String?)
}

// MARK: - TripDetailNetworkRepositoryType

public protocol TripDetailNetworkRepositoryType: TripDetailRepositoryType {}

// MARK: - TripDetailCacheRepositoryType

public protocol TripDetailCacheRepositoryType: TripDetailRepositoryType {}
