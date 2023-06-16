import Foundation

class MonthlyStatsNetworkRepository: MonthlyStatsNetworkRepositoryType {
    func loadData(for dateWithId: String?, vehicleId vId: String?, clearCache: Bool, completion: @escaping (Result<MonthlyStatsDataType, Error>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterMonthlyStats.monthlyStats(dateWithId, vId)) { (result: Result<NetworkMonthlyStatsData, Error>) in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func loadPreviousMonths(clearCache: Bool, vehicleId vId: String?, completion: @escaping (Result<[MonthSelectorItem], Error>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterMonthlyStats.listReports(vId)) { (result: Result<NetworkMonthlyStatMonthScore, Error>) in
            switch result {
            case let .success(data):
                let monthList = data.monthList
                let monthItems: [MonthSelectorItem] = monthList.map {
                    MonthSelectorItem(monthItem: $0)
                }
                completion(.success(monthItems))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
