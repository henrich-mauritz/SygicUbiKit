import Foundation

public class RewardsNetworkRepository: RewardsNetworkRepositoryType {
    public func fetchRewardsAvailable(_ completion: @escaping (Result<RewardsListDataType, RewardError>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterRewards.rewards(ApiRouterRewards.RewardsRequestData()), completion: { (result: Result<NetworkRewardsList, Error>) in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                let retError = RewardError(from: error)
                completion(.failure(retError))
            }
        })
    }

    public func fetchRewardsAwarded(_ completion: @escaping (Result<RewardsListDataType, RewardError>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterRewards.rewardsAwarded(ApiRouterRewards.RewardsRequestData()), completion: { (result: Result<NetworkRewardsList, Error>) in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                let retError = RewardError(from: error)
                completion(.failure(retError))
            }
        })
    }

    public func fetchReward(with rewardId: String, completion: @escaping (Result<RewardDataType, Error>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterRewards.reward(rewardId)) { (result: Result<NetworkRewardDetail, Error>) in
            switch result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func participate(with rewardId: String, completion: @escaping ((Error?) -> ())) {
        NetworkManager.shared.requestAPI(ApiRouterRewards.participation(rewardId)) { error in
            completion(error)
        }
    }

    public func checkForNewContents(completion: @escaping (Result<NetworkWhatsNewRewardsData?, Error>) -> ()) {
        let lastDate = UserDefaults.standard.value(forKey: RewardsModule.UserDefaultKeys.lastChangeDateKey) as? Date ?? Date()
        NetworkManager.shared.requestAPI(ApiRouterRewards.whatsNew(lastDate)) { (result: Result<NetworkWhatsNewRewardsData?, Error>) in
            switch result {
            case let .failure(error):
                print("There was an error fetching whats new badges \(error.localizedDescription)")
            case let .success(data):
                UserDefaults.standard.setValue(data?.lastChangeDate, forKey: RewardsModule.UserDefaultKeys.lastChangeDateKey)
            }
            completion(result)
        }
    }

    public func claimReward(with id: String, completion: @escaping (Result<NetworkRewardClaim, Error>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterRewards.claim(id)) { (result: Result<NetworkRewardClaim, Error>) in
            completion(result)
        }
    }
}
