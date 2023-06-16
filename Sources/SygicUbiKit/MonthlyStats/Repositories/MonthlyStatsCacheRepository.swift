import Foundation

class MonthlyStatsCacheRepository: MonthlyStatsCacheRepositoryType {
    func loadData(for dateWithId: String?, vehicleId vId: String?, clearCache: Bool, completion: @escaping (Result<MonthlyStatsDataType, Error>) -> ()) {}

    func loadPreviousMonths(clearCache: Bool, vehicleId vId: String?, completion: @escaping (Result<[MonthSelectorItem], Error>) -> ()) {}
}
