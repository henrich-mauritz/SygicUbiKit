import Foundation
import UIKit

// MARK: - RewardsViewModelDelegate

public protocol RewardsViewModelDelegate: AnyObject {
    func viewModelUpdated(_ sender: Any)
    func viewModelDidFail(with error: Error)
}

// MARK: - RewardsListViewModelProtocol

public protocol RewardsListViewModelProtocol: AnyObject {
    var delegate: RewardsViewModelDelegate? { get set }
    var rewardsFilter: RewardsFilter { get set }
    var rewardsAvailable: Bool { get }
    var rewards: [RewardViewModelProtocol] { get }
    var hasNewGainedReward: Bool { get }
    var loadingData: Bool { get }
    func reloadData(cleanCache: Bool)
}

// MARK: - RewardViewModelProtocol

public protocol RewardViewModelProtocol: InfoItemType {
    var conditions: [Bool] { get }
    var rewardCode: String? { get }
    var gainedRewardSubtitleText: String? { get }
    var type: NetworkRewardContainer.ContentType { get }
    func detailViewModel(with delegate: RewardsViewModelDelegate?) -> RewardDetailViewModelProtocol?
}
