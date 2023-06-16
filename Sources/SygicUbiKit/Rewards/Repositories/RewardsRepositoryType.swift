import Foundation

// MARK: - RewardRepositoryError

public enum RewardRepositoryError: LocalizedError {
    case cacheNotFound(detailId: String?)
    case unknown

    public var errorDescription: String? {
        switch self {
        case let .cacheNotFound(detailId):
            return "cache for detail ::: \(detailId ?? "LIST") :::, not found"
        default:
            return "unknown"
        }
    }
}

// MARK: - RewardsRepositoryType

public protocol RewardsRepositoryType {
    func fetchRewardsAvailable(_ completion: @escaping (Result<RewardsListDataType, RewardError>) -> ())
    func fetchRewardsAwarded(_ completion: @escaping (Result<RewardsListDataType, RewardError>) -> ())
    func checkForNewContents(completion: @escaping (Result<NetworkWhatsNewRewardsData?, Error>) -> ())
    func fetchReward(with rewardId: String, completion: @escaping (Result<RewardDataType, Error>) -> ())
    func participate(with rewardId: String, completion: @escaping ((Error?) -> ()))
    func purgeData()
    func purgeData(for rewardId: String)
    func store(rewards: RewardsListDataType, awarded: Bool)
    func store(reward: RewardDataType)
    func claimReward(with id: String, completion: @escaping (Result<RewardDataType, Error>) -> ())
}

public extension RewardsRepositoryType {
    func store(rewards: RewardsListDataType, awarded: Bool) {}
    func store(reward: RewardDataType) {}
    func checkForNewContents(completion: @escaping (Result<NetworkWhatsNewRewardsData?, Error>) -> ()) {}
    func claimReward(with id: String, completion: @escaping (Result<RewardDataType, Error>) -> ()) {}
}

// MARK: - RewardsNetworkRepositoryType

public protocol RewardsNetworkRepositoryType: RewardsRepositoryType {
    func claimReward(with id: String, completion: @escaping (Result<NetworkRewardClaim, Error>) -> ())
}

public extension RewardsNetworkRepositoryType {
    func store(reward: RewardDataType) {}
    func store(rewards: RewardsListDataType, awarded: Bool) {}
    func purgeData() {}
    func purgeData(for rewardId: String) {}
}

// MARK: - RewardsCacheRepositoryType

public protocol RewardsCacheRepositoryType: RewardsRepositoryType {}

public extension RewardsCacheRepositoryType {
    func participate(with rewardId: String, completion: @escaping ((Error?) -> ())) {
        // nothing to do
    }
}
