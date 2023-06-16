import Foundation

// MARK: - RewardsCacheRepository

public class RewardsCacheRepository: RewardsCacheRepositoryType {
    private var rewardsAvailable: [RewardListItemType]?
    private var rewardsAwarded: [RewardListItemType]?
    private var rewardDetails: [String: RewardDataType] = [String: RewardDataType]()

    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.loggoutNotification), name: .userLoggedOut, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func fetchRewardsAvailable(_ completion: @escaping (Result<RewardsListDataType, RewardError>) -> ()) {
        guard let rewards = rewardsAvailable else {
            completion(.failure(RewardError.cacheNotFound(detailId: nil)))
            return
        }
        completion(.success(CachedRewardList(items: rewards)))
    }

    public func fetchRewardsAwarded(_ completion: @escaping (Result<RewardsListDataType, RewardError>) -> ()) {
        guard let rewards = rewardsAwarded else {
            completion(.failure(RewardError.cacheNotFound(detailId: nil)))
            return
        }
        completion(.success(CachedRewardList(items: rewards)))
    }

    public func fetchReward(with rewardId: String, completion: @escaping (Result<RewardDataType, Error>) -> ()) {
        if let cached = rewardDetails[rewardId] {
            completion(.success(cached))
        } else {
            completion(.failure(RewardRepositoryError.cacheNotFound(detailId: rewardId)))
        }
    }

    public func store(rewards: RewardsListDataType, awarded: Bool) {
        if awarded {
            if rewardsAwarded == nil {
                rewardsAwarded = []
            }
            rewardsAwarded?.append(contentsOf: rewards.items)
            checkForConsistency(of: &rewardsAwarded!)
        } else {
            if rewardsAvailable == nil {
                rewardsAvailable = []
            }
            rewardsAvailable?.append(contentsOf: rewards.items)
            checkForConsistency(of: &rewardsAvailable!)
        }
    }

    public func store(reward: RewardDataType) {
        rewardDetails[reward.id] = reward
    }

    public func purgeData() {
        rewardsAwarded = nil
        rewardsAvailable = nil
        rewardDetails.removeAll()
    }

    public func purgeData(for rewardId: String) {
        rewardDetails.removeValue(forKey: rewardId)
    }

    @objc
private func loggoutNotification() {
        purgeData()
    }

    private func checkForConsistency(of array: inout [RewardListItemType]) {
        //sometimes the cahce will contain old data from previous multip async fetches..
        //for sake of consistency we will remove the duplicates
        let cleaned = array.uniq(by: \.id)
        array = cleaned
    }
}

// MARK: - CachedRewardList

private struct CachedRewardList: RewardsListDataType {
    var items: [RewardListItemType]
}
