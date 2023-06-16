import Foundation
import UIKit

// MARK: - RewardsListDataType

public protocol RewardsListDataType {
    var items: [RewardListItemType] { get }
}

// MARK: - RewardListItemType

public protocol RewardListItemType {
    var id: String { get }
    var imageLightUri: String { get }
    var imageDarkUri: String { get }
    var title: String { get }
    var subtitle: String? { get }
    var description: String { get }
    var fulfilledRequirementCount: Int { get }
    var requirementCount: Int { get }
    var validUntil: Date? { get }
    var rewardCode: String? { get }
    var state: ContentRewardState? { get }
    var type: NetworkRewardContainer.ContentType { get }
}

// MARK: - RewardDataType

public protocol RewardDataType {
    var id: String { get }
    var thumbnailUri: String? { get }
    var imageUri: String { get }
    var title: String { get }
    var subtitle: String? { get }
    var description: String? { get }
    var requirements: NetworkReward.NetworkRewardDetailRequirements { get }
    var validUntil: Date? { get }
    var rewardCode: String? { get }
    var howToInstructions: RewardInstructionType? { get }
    var conditions: RewardTermsAndConditionsType? { get }
    var isParticipating: Bool { get set }
    var rewardState: ContentRewardState { get }
    var type: NetworkRewardContainer.ContentType? { get }
    var rewardInsturctions: String? { get }
    func update(with claimedData: NetworkRewardClaim)
}

public extension RewardDataType {
    var isGained: Bool {
        if let code = rewardCode, code.count > 0 {
            return true
        }
        return false
    }

    func update(with claimedData: NetworkRewardClaim) {}
}

// MARK: - RewardRequirement

public struct RewardRequirement: Codable {
    var text: String
    var isFulfilled: Bool
}

// MARK: - RewardInstructionType

public protocol RewardInstructionType {
    var title: String { get }
    var description: String { get }
}

// MARK: - RewardInstruction

public struct RewardInstruction: RewardInstructionType, Codable {
    public var title: String
    public var description: String
}

// MARK: - RewardTermsAndConditionsType

//MARK: - TermsAndConditions

public protocol RewardTermsAndConditionsType {
    var text: String { get }
    var termsAndConditionsUri: String? { get }
    var agreedToTermsAndConditions: Bool { get }
}

// MARK: - RewardTermAndConditions

public struct RewardTermAndConditions: RewardTermsAndConditionsType, Codable {
    public var text: String
    public var termsAndConditionsUri: String?
    public var agreedToTermsAndConditions: Bool
}

// MARK: - RewardsStyleConfigurable

//MARK: - StylingConfigurable

public protocol RewardsStyleConfigurable {
    var conditionColor: UIColor { get }
    var conditionCornerRadious: CGFloat { get }
}

// MARK: - RewardsStyling

public struct RewardsStyling: RewardsStyleConfigurable {
    public var conditionColor: UIColor = .positivePrimary
    public var conditionCornerRadious: CGFloat = 4.5
}
