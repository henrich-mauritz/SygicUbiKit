import Foundation

// MARK: - MonthlyStatsRepositoryType

public protocol MonthlyStatsRepositoryType {
    func loadData(for dateWithId: String?, vehicleId vId: String?, clearCache: Bool, completion: @escaping (Result<MonthlyStatsDataType, Error>) -> ())
    func loadPreviousMonths(clearCache: Bool, vehicleId vId: String?, completion: @escaping (Result<[MonthSelectorItem], Error>) -> ())
}

// MARK: - MonthlyStatsNetworkRepositoryType

public protocol MonthlyStatsNetworkRepositoryType: MonthlyStatsRepositoryType {}

// MARK: - MonthlyStatsCacheRepositoryType

public protocol MonthlyStatsCacheRepositoryType: MonthlyStatsRepositoryType {}
