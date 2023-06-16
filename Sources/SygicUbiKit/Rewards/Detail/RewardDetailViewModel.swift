import Foundation

// MARK: - RewardDetailViewModelProtocol

public protocol RewardDetailViewModelProtocol {
    var delegate: RewardsViewModelDelegate? { get set }
    var imageUri: String { get }
    var title: String { get }
    var subtitle: String? { get }
    var description: String? { get }
    var requirements: [RewardRequirement] { get }
    var rewardCode: String? { get }
    var rewardValid: String? { get }
    var isUnlimited: Bool { get }
    var participating: Bool { get }
    var instructions: RewardInstructionType? { get }
    var termsAndConditions: RewardTermsAndConditionsType? { get }
    var loading: Bool { get }
    var rewardId: String { get }
    var requirementsSubtitle: String { get }
    var gainedRewardAdditionalText: String? { get }
    var state: ContentRewardState { get }
    var type: NetworkRewardContainer.ContentType? { get }
    func participate()
    func claimEligibleReward()
}

// MARK: - RewardDetailError

public enum RewardDetailError: LocalizedError {
    case participationFailed
    case unknown
    case claimFailed

    public var errorDescription: String? {
        switch self {
        case .participationFailed:
            return "rewards.error.participate".localized
        case .claimFailed:
            return "rewards.error.outdated".localized
        default:
            return "rewards.error.unknown".localized
        }
    }
}

// MARK: - RewardDetailViewModel

public class RewardDetailViewModel: RewardDetailViewModelProtocol, InjectableType {
    public var type: NetworkRewardContainer.ContentType? { model?.type }
    public weak var delegate: RewardsViewModelDelegate?
    public var rewardId: String { model?.id ?? "" }
    public var title: String { model?.title ?? "" }
    public var subtitle: String? { model?.subtitle ?? "" }
    public var requirements: [RewardRequirement] { model?.requirements.requirements ?? [] }
    public var imageUri: String { model?.imageUri ?? "" }
    public var description: String? { model?.description }
    public var rewardCode: String? {
        guard let code = model?.rewardCode else { return nil }
        return code
    }

    public var participating: Bool { model?.isParticipating ?? false }
    public var instructions: RewardInstructionType? { model?.howToInstructions }
    public var termsAndConditions: RewardTermsAndConditionsType? { model?.conditions }
    public var requirementsSubtitle: String { model?.requirements.subtitle ?? "rewards.detail.requirementsTitle".localized }
    public var gainedRewardAdditionalText: String? { model?.rewardInsturctions }
    public var state: ContentRewardState { model?.rewardState ?? .none}
    public var rewardValid: String? {
        guard let date = model?.validUntil else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    public var isUnlimited: Bool {
        guard let date = model?.validUntil else {
            return true
        }
        return date.compare(Date.maxDate()) == .orderedSame
    }

    public private(set) var loading: Bool = false

    private var model: RewardDataType? {
        didSet {
            delegate?.viewModelUpdated(self)
        }
    }

    private lazy var repository: RewardsRepositoryType = container.resolveRewardsRepo()

    public init(with reward: RewardDataType) {
        model = reward
        container.injectRewardsRepo()
    }

    public init(with rewardID: String, delegate: RewardsViewModelDelegate? = nil) {
        container.injectRewardsRepo()
        self.delegate = delegate
        loadRewardDetail(rewardID)
    }

    public func participate() {
        guard let rewardId = model?.id else { return }
        loading = true
        repository.participate(with: rewardId) { [weak self] error in
            guard let self = self else { return }
            guard error == nil else {
                self.loading = false
                self.delegate?.viewModelDidFail(with: RewardDetailError.participationFailed)
                return
            }
            self.repository.purgeData(for: rewardId)
            self.model?.isParticipating = true
            self.loading = false
            self.delegate?.viewModelUpdated(self)
            //self?.loadRewardDetail(rewardId)
        }
    }

    private func loadRewardDetail(_ rewardId: String) {
        loading = true
        repository.fetchReward(with: rewardId, completion: { [weak self] result in
            guard let self = self else {
                return
            }
            self.loading = false
            switch result {
            case let .success(reward):
                self.model = reward
                self.delegate?.viewModelUpdated(self)
            case let .failure(error):
                self.delegate?.viewModelDidFail(with: error)
            }
        })
    }

    public func claimEligibleReward() {
        repository.claimReward(with: rewardId) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.delegate?.viewModelUpdated(self)
                NotificationCenter.default.post(name: .forceReloadRewardsList, object: nil)
            case let .failure(error):
                guard let rewardError = error as? NetworkError else {
                    self.delegate?.viewModelDidFail(with: error)
                    return
                }

                if rewardError.httpErrorCode == 422 {
                    self.delegate?.viewModelDidFail(with: RewardDetailError.claimFailed)
                } else {
                    self.delegate?.viewModelDidFail(with: rewardError)
                }
            }
        }
    }
}
