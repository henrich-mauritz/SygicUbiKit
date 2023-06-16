import Foundation

public class RewardsRepository: RewardsRepositoryType {
    let networkReposotory: RewardsNetworkRepositoryType
    let cacheRepository: RewardsCacheRepositoryType

    public init(with networkRepo: RewardsNetworkRepositoryType, cacheRepo: RewardsCacheRepositoryType) {
        networkReposotory = networkRepo
        cacheRepository = cacheRepo
    }

    public func fetchRewardsAvailable(_ completion: @escaping (Result<RewardsListDataType, RewardError>) -> ()) {
        cacheRepository.fetchRewardsAvailable { [weak self] cachedResult in
            switch cachedResult {
            case let .success(data):
                completion(.success(data))
            case .failure:
                self?.networkReposotory.fetchRewardsAvailable { result in
                    switch result {
                    case let .success(data):
                        self?.cacheRepository.store(rewards: data, awarded: false)
                        completion(.success(data))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    public func fetchRewardsAwarded(_ completion: @escaping (Result<RewardsListDataType, RewardError>) -> ()) {
        cacheRepository.fetchRewardsAwarded { [weak self] cachedResult in
            switch cachedResult {
            case let .success(data):
                completion(.success(data))
            case .failure:
                self?.networkReposotory.fetchRewardsAwarded { result in
                    switch result {
                    case let .success(data):
                        self?.cacheRepository.store(rewards: data, awarded: true)
                        completion(.success(data))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    public func fetchReward(with rewardId: String, completion: @escaping (Result<RewardDataType, Error>) -> ()) {
        cacheRepository.fetchReward(with: rewardId) { [weak self] cacheResult in
            switch cacheResult {
            case let .success(data):
                completion(.success(data))
            case .failure(_):
                self?.networkReposotory.fetchReward(with: rewardId, completion: { result in
                    switch result {
                    case let .success(data):
                        self?.cacheRepository.store(reward: data)
                        completion(.success(data))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                })
            }
        }
    }

    public func participate(with rewardId: String, completion: @escaping ((Error?) -> ())) {
        networkReposotory.participate(with: rewardId) { error in
            completion(error)
        }
    }

    public func purgeData() {
        cacheRepository.purgeData()
    }

    public func purgeData(for rewardId: String) {
        cacheRepository.purgeData(for: rewardId)
    }

    public func checkForNewContents(completion: @escaping (Result<NetworkWhatsNewRewardsData?, Error>) -> ()) {
        networkReposotory.checkForNewContents(completion: completion)
    }

    public func claimReward(with id: String, completion: @escaping (Result<RewardDataType, Error>) -> ()) {
        networkReposotory.claimReward(with: id) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.cacheRepository.fetchReward(with: id) { cachedResult in
                    switch cachedResult {
                    case let .success(reward):
                        reward.update(with: data)
                        completion(.success(reward))
                    case .failure(_):
                        print("Reward wasn't cached")
                    }
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
