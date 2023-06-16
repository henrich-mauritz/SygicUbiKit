import Foundation

public struct TriplogMonthlyRepository: TriplogMonthlyRepositoryType {
    let networkReposotory: TriplogMonthlyNewtworkRepositoryType
    let cacheRepository: TriplogMonthlyCacheRepositoryType

    public func fetchMonthlyData(with requestData: ApiRouterTriplog.TripsRequestData, completion: @escaping (Result<TriplogTripsDataType, Error>) -> ()) {
        cacheRepository.fetchMonthlyData(with: requestData) { cacheResult in
            switch cacheResult {
            case let .success(data):
                completion(.success(data))
            case .failure(_):
                networkReposotory.fetchMonthlyData(with: requestData) { networkResult in
                    switch networkResult {
                    case let .success(data):
                        cacheRepository.store(data: data, with: requestData)
                        completion(.success(data))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    public func pageCount(forDataWith id: String) -> Int {
        return cacheRepository.pageCount(forDataWith: id)
    }

    public func purgeData() {
        cacheRepository.purgeData()
    }

    public func purgueData(for id: String) {
        cacheRepository.purgueData(for: id)
    }
}
