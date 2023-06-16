import Foundation

// MARK: - RewardsFilter

public enum RewardsFilter {
    case available
    case gained

    public var localizedString: String {
        switch self {
        case .available:
            return "rewards.segmentAvailable".localized.uppercased()
        case .gained:
            return "rewards.segmentGained".localized.uppercased()
        }
    }

    static func filter(for index: Int) -> RewardsFilter {
        index == 0 ? .available : .gained
    }
}

// MARK: - RewardsListViewModel

public class RewardsListViewModel: RewardsListViewModelProtocol, InjectableType {
    public weak var delegate: RewardsViewModelDelegate?
    private lazy var vehicleRepository: VehicleProfileRepositoryType = container.resolveVehicleProfileRepo()
    public var rewardsFilter: RewardsFilter = .available {
        didSet {
            guard rewardsFilter != oldValue else { return }
            if rewardsFilter == .gained {
                hasNewGainedReward = false
            }
            reloadData()
            delegate?.viewModelUpdated(self)
        }
    }

    public private(set) var rewardsAvailable: Bool = true

    public var rewards: [RewardViewModelProtocol] {
        switch rewardsFilter {
        case .available:
            return availableRewards ?? []
        case .gained:
            return awardedRewards ?? []
        }
    }

    public private(set) var hasNewGainedReward: Bool = false
    public private(set) var loadingData: Bool = false
    private lazy var repository: RewardsRepositoryType = {
        container.resolve(RewardsRepositoryType.self)!
    }()

    private var data: RewardsListDataType? {
        didSet {
            delegate?.viewModelUpdated(self)
        }
    }

    private var availableRewards: [RewardViewModelProtocol]?
    private var awardedRewards: [RewardViewModelProtocol]?
    private var notificationsObservers = [NSObjectProtocol]()

    public init() {
        container.injectRewardsRepo()
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification(_:)), name: .newRewardNotification, object: nil)
        observeNetworkChange()
    }

    deinit {
        notificationsObservers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }

    @objc
private func receiveNotification(_ notification: NSNotification) {
        hasNewGainedReward = true
        delegate?.viewModelUpdated(self)
    }

    public func reloadData(cleanCache: Bool = false) {
        if cleanCache {
            repository.purgeData()
        }
        loadingData = true
        if rewardsFilter == .available {
            repository.fetchRewardsAvailable { [weak self] result in
                self?.processRewardsResult(result, awarded: false)
            }
        } else {
            repository.fetchRewardsAwarded { [weak self] result in
                self?.processRewardsResult(result, awarded: true)
            }
        }
    }

    private func processRewardsResult(_ result: Result<RewardsListDataType, RewardError>, awarded: Bool) {
        loadingData = false
        switch result {
        case let .success(rewardsData):
            let items: [RewardListItemViewModel] = rewardsData.items.map { RewardListItemViewModel(model: $0) }
            if awarded {
                awardedRewards = items
            } else {
                availableRewards = items
            }
            rewardsAvailable = true
            data = rewardsData
            self.delegate?.viewModelUpdated(self)
        case let .failure(error):
            if error == .unavailable {
                rewardsAvailable = false
            }
            repository.purgeData()
            availableRewards?.removeAll()
            awardedRewards?.removeAll()
            delegate?.viewModelDidFail(with: error)
        }
    }
}

extension RewardsListViewModel {
    func observeNetworkChange() {
        notificationsObservers.append(NotificationCenter.default.addObserver(forName: .flagsChanged,
                                                                             object: nil,
                                                                             queue: nil) {[weak self] _ in
                                                DispatchQueue.main.async {
                                                    switch ReachabilityManager.shared.status {
                                                    case .wwan, .wifi:
                                                        self?.reloadData(cleanCache: true)
                                                    default:
                                                        print("no connection reached")
                                                    }
                                                }
        })
    }
}

// MARK: - RewardListItemViewModel

struct RewardListItemViewModel: RewardViewModelProtocol {
    var imageUri: String { model.imageLightUri }

    var imageDarkUri: String? { model.imageDarkUri }

    var title: String { model.title }

    var subtitle: String? { model.subtitle }

    var rewardCode: String? {
        guard let code = model.rewardCode else { return nil }
        return "\("rewards.detail.yourCodePrefix".localized): \(code)"
    }

    var type: NetworkRewardContainer.ContentType { model.type }

    var description: String? {
        if model.type == .custom {
            return model.description
        }

        if let subtitle = subtitle, subtitle.count > 0, conditions.count > 0 {
            return nil
        }
        return model.description
    }

    var conditions: [Bool] {
        if let code = model.rewardCode, !code.isEmpty {
            return []
        }
        var conditions: [Bool] = []
        for i in 0 ..< model.requirementCount {
            conditions.append(i < model.fulfilledRequirementCount)
        }
        return conditions
    }

    var gainedRewardSubtitleText: String? {
        guard let state = model.state else { return nil }
        if state == .eligibleForReward {
            return "rewards.detail.eligibleConfirmSubtitle".localized
        }
        return nil
    }

    let model: RewardListItemType

    public func detailViewModel(with delegate: RewardsViewModelDelegate? = nil) -> RewardDetailViewModelProtocol? {
        RewardDetailViewModel(with: model.id, delegate: delegate)
    }
}
