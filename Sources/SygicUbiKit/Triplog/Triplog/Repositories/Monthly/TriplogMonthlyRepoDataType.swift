import Foundation

// MARK: - TriplogMonthRepositoryError

public enum TriplogMonthRepositoryError: LocalizedError {
    case cacheNotFound(detailId: String)
    case unknown

    public var errorDescription: String? {
        switch self {
        case let .cacheNotFound(detailId):
            return "cache for detail ::: \(detailId) :::, not found"
        default:
            return "unknown"
        }
    }
}

// MARK: - TriplogMonthlyRepositoryType

public protocol TriplogMonthlyRepositoryType {
    func pageCount(forDataWith id: String) -> Int
    func fetchMonthlyData(with requestData: ApiRouterTriplog.TripsRequestData, completion: @escaping (Result<TriplogTripsDataType, Error>) -> ())
    func purgeData()
    func purgueData(for id: String)
}

extension TriplogMonthlyRepositoryType {
    public func pageCount(forDataWith id: String) -> Int { return 0 }
    func purgeData() {}
    func purgueData(for id: String) {}
}

// MARK: - TriplogMonthlyNewtworkRepositoryType

public protocol TriplogMonthlyNewtworkRepositoryType: TriplogMonthlyRepositoryType {}

// MARK: - TriplogMonthlyCacheRepositoryType

public protocol TriplogMonthlyCacheRepositoryType: TriplogMonthlyRepositoryType {
    var dataCache: [ApiRouterTriplog.TripsRequestData: TriplogTripsDataType] { get set }
    func store(data: TriplogTripsDataType, with dataKey: ApiRouterTriplog.TripsRequestData)
    func purgeData()
    func purgueData(for id: String)
}
