import Foundation

struct MonthlyStatsRepository: MonthlyStatsRepositoryType {
    let networkRepo: MonthlyStatsNetworkRepositoryType
    let cahceRepo: MonthlyStatsCacheRepositoryType

    func loadData(for dateWithId: String?, vehicleId vId: String?, clearCache: Bool, completion: @escaping (Result<MonthlyStatsDataType, Error>) -> ()) {
        networkRepo.loadData(for: dateWithId, vehicleId: vId, clearCache: clearCache, completion: completion)
    }

    func loadPreviousMonths(clearCache: Bool, vehicleId vId: String?, completion: @escaping (Result<[MonthSelectorItem], Error>) -> ()) {
        networkRepo.loadPreviousMonths(clearCache: clearCache, vehicleId: vId, completion: completion)
    }
}
