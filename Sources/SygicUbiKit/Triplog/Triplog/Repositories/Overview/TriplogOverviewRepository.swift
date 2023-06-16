import Foundation

// MARK: - TriplogOverviewRepository

public class TriplogOverviewRepository: TriplogOverviewRepositoryType {
    let networkRepository: TriplogOverviewNetworkRepositoryType
    var cacheRepository: TriplogOverviewCacheRepositoryType

    init(with networkRepo: TriplogOverviewNetworkRepositoryType, cacheRepo: TriplogOverviewCacheRepositoryType) {
        self.networkRepository = networkRepo
        self.cacheRepository = cacheRepo
    }
}

public extension TriplogOverviewRepository {
    func fetch(overviewWith archiveId: String?, vehicleID: String? = nil, _ completion: @escaping (Result<TriplogOverviewDataType, Error>) -> ()) {
        if let archiveId = archiveId, let data = cacheRepository.archiveData?[archiveId] {
            completion(.success(data))
            return
        }
        networkRepository.fetch(overviewWith: archiveId, vehicleID: vehicleID) {[weak self] result in
            switch result {
            case let .success(data):
                if let archiveId = archiveId {
                    self?.cacheRepository.archiveData?[archiveId] = data
                } else {
                    self?.cacheRepository.data = data
                }
                completion(result)
            case .failure(_):
                completion(result)
            }
        }
    }
}

//MARK: Cache specific

public extension TriplogOverviewRepository {
    var data: TriplogOverviewDataType? {
        return cacheRepository.data
    }

    func cardOverviewModel(for data: TriplogOverviewCardDataType) -> TriplogOverviewCardDataType? {
        return cacheRepository.cardOverviewModel(for: data)
    }

    func archivedData(with id: String) -> TriplogOverviewDataType? {
        return cacheRepository.archivedData(with: id)
    }

    func purgueData() {
        cacheRepository.purgueData()
    }
}
