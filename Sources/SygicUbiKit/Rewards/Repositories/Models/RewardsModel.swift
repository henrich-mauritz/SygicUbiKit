import Foundation

// MARK: - NetworkRewardsList

public struct NetworkRewardsList: Codable {
    struct Contests: Codable {
        var page: Int
        var pageSize: Int
        var pagesCount: Int
        var totalItemsCount: Int
        var items: [NetworkRewardsListItem]
    }

    struct Container: Codable {
        var contests: Contests
    }

    var data: Container
}

// MARK: RewardsListDataType

extension NetworkRewardsList: RewardsListDataType {
    public var items: [RewardListItemType] { data.contests.items }
}

// MARK: - NetworkRewardImage

public struct NetworkRewardImage: Codable {
    var lightUri: String
    var darkUri: String?
}

// MARK: - NetworkRewardContainer

public struct NetworkRewardContainer: Codable {
    public enum ContentType: String, Codable {
        case code
        case custom
    }

    struct Payload: Codable {
        var validUntil: Date?
        var code: String?
        var instructions: String?
    }

    struct ContestRewardContent: Codable {
        var type: ContentType
        var payload: Payload
    }

    var state: ContentRewardState
    var content: ContestRewardContent?
}

// MARK: - NetworkRewardsListItem

public struct NetworkRewardsListItem: Codable, RewardListItemType {
    public var id: String
    public var image: NetworkRewardImage
    public var title: String
    public var subtitle: String?
    public var description: String
    public var fulfilledRequirementCount: Int
    public var requirementCount: Int
    public var imageLightUri: String { image.lightUri }
    public var imageDarkUri: String { image.darkUri ?? image.lightUri }
    public var validUntil: Date? { reward?.content?.payload.validUntil }
    public var rewardCode: String? { reward?.content?.payload.code }
    public var state: ContentRewardState? { reward?.state }
    public var type: NetworkRewardContainer.ContentType { reward?.content?.type ?? .code }
    var reward: NetworkRewardContainer?
}

// MARK: - NetworkRewardDetail

public struct NetworkRewardDetail: Codable {
    public var data: NetworkReward
}

// MARK: - ContentRewardState

public enum ContentRewardState: String, Codable {
    case none
    case eligibleForReward
    case gained
}

// MARK: - NetworkReward

public class NetworkReward: Codable {
    public struct NetworkRewardDetailRequirements: Codable {
        public var subtitle: String
        public var requirements: [RewardRequirement]
    }

    public struct TimePeriod: Codable {
        public var periodStart: Date
        public var periodEnd: Date
    }

    public struct RewardGained: Codable {
        public var rewardCode: String
        public var validUntil: Date
        public var rewardInstructions: String?
    }

    public var id: String
    var image: NetworkRewardImage
    public var title: String
    public var subtitle: String?
    public var description: String?
    public var requirements: NetworkRewardDetailRequirements
    public var instructions: RewardInstruction?
    public var isParticipating: Bool
    public var termsAndConditions: RewardTermAndConditions?
    public var reward: NetworkRewardContainer
}

// MARK: RewardDataType

extension NetworkReward: RewardDataType {
    public var howToInstructions: RewardInstructionType? { instructions }
    public var conditions: RewardTermsAndConditionsType? { termsAndConditions }
    public var thumbnailUri: String? { image.lightUri }
    public var validUntil: Date? { reward.content?.payload.validUntil }
    public var rewardCode: String? { reward.content?.payload.code }
    public var imageUri: String { image.lightUri }
    public var rewardInsturctions: String? { reward.content?.payload.instructions }
    public var rewardState: ContentRewardState { reward.state }
    public var type: NetworkRewardContainer.ContentType? { reward.content?.type }
    public func update(with claimedData: NetworkRewardClaim) {
        self.reward = NetworkRewardContainer(state: .gained,
                                             content: claimedData.data)
    }
}

// MARK: - NetworkRewardClaim

//MARK: RewardClaimResponse

public struct NetworkRewardClaim: Codable {
    var data: NetworkRewardContainer.ContestRewardContent
    var code: String? { data.payload.code }
    var rewardInstructions: String? { data.payload.instructions }
    var validUntil: Date? { data.payload.validUntil }
}
