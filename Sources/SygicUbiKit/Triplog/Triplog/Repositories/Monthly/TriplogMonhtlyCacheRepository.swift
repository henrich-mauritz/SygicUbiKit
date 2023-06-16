import Foundation

class TriplogMonthlyCacheRepository: TriplogMonthlyCacheRepositoryType {
    var dataCache: [ApiRouterTriplog.TripsRequestData: TriplogTripsDataType] = [:]

    func fetchMonthlyData(with requestData: ApiRouterTriplog.TripsRequestData, completion: @escaping (Result<TriplogTripsDataType, Error>) -> ()) {
        guard let cachedData = dataCache[requestData] else {
            completion(.failure(TriplogMonthRepositoryError.cacheNotFound(detailId: requestData.detailId)))
            return
        }
        completion(.success(cachedData))
    }

    func store(data: TriplogTripsDataType, with dataKey: ApiRouterTriplog.TripsRequestData) {
            self.dataCache[dataKey] = data
    }

    public func pageCount(forDataWith id: String) -> Int {
        let keyVal = dataCache.filter {
            $0.key.detailId == id
        }.max { p1, p2 -> Bool in
            p1.key.page > p2.key.page
        }
        guard let tripData = keyVal?.value as? NetworkTripsData else {
            return 0
        }
        return tripData.data.trips.pagesCount
    }

    public func purgeData() {
        dataCache = [:]
    }

    public func purgueData(for id: String) {
        let keyVal = dataCache.filter {
            $0.key.detailId == id
        }
        if let anyKey = keyVal.keys.first {
            dataCache[anyKey] = nil
        } else {
            print("::Warning:: No data cached for key with id \(id)")
        }
    }
}
