import Foundation
import UIKit

// MARK: - DiscountsState

public enum DiscountsState {
    case initial
    case progress
    case claimed
}

// MARK: - DiscountError

public enum DiscountError: String {
    case unknown
    case nothingToClaim
    case incompleteProfile

    func localized() -> String {
        switch self {
        case .unknown:
            return "discounts.discountError.unknownErrorMessage".localized
        case .nothingToClaim:
            return "discounts.discountError.nothingToClaimMessage".localized
        case .incompleteProfile:
            return "discounts.discountError.incompleteProfileMessage".localized
        }
    }
}

// MARK: - DiscountsViewModelDelegate

public protocol DiscountsViewModelDelegate: AnyObject {
    func viewModelDidBegingUpdating()
    func viewModelUpdated(_ sender: Any)
    func viewModelError(_ message: String, error: DiscountError)
    func viewModelDidFail(with error: Error)
}

public extension DiscountsViewModelDelegate {
    func viewModelDidBegingUpdating() {}
    func viewModelError(_ message: String, error: DiscountError) {}
}

// MARK: - DiscountsViewModelType

public protocol DiscountsViewModelType: AnyObject {
    var delegate: DiscountsViewModelDelegate? { get set }
    // var loading: Bool { get }
    var state: DiscountsState { get }
    var challengeViewModel: DiscountChallengeViewModelProtocol? { get }
    var claimedDiscount: DiscountClaimedViewModelType? { get }
    var claimableDiscount: DiscountClaimable? { get }
    var infoDetails: [(icon: UIImage?, title: String)] { get }
    var maxDiscountAvailable: Bool { get }
    var currentFilteringVehicle: VehicleProfileType? { get set }
    var hasMoreThanOneVehicle: Bool { get }
    func reloadData(completion: @escaping ((_ finished: Bool) -> Void))
    func claimDiscount(completion: @escaping ((_ finished: Bool) -> Void))
}

// MARK: - DiscountChallengeViewModelProtocol

public protocol DiscountChallengeViewModelProtocol {
    var title: String { get }
    var description: String { get }
    var steps: [DiscountChallengeStepViewModelProtocol] { get }
    func isUnderRequirement() -> Bool
}

public extension DiscountChallengeViewModelProtocol {
    func isUnderRequirement() -> Bool { false }
}

// MARK: - DiscountChallengeStepViewModelProtocol

public protocol DiscountChallengeStepViewModelProtocol: ProgressColoring {
    var stepProgress: Double { get }
    var stepProgressTitle: String { get }
    var stepProgressSubtitle: String? { get }
    var stepTargetAmount: String { get }
}

// MARK: - DiscountClaimedViewModelType

public protocol DiscountClaimedViewModelType {
    var claimedTitle: String { get }
    var claimedCode: String { get }
    var claimedValidity: String { get }
    var isValid: Bool { get }
}

// MARK: - DiscountClaimable

public protocol DiscountClaimable {
    var amount: String { get }
    var canBeClaimed: Bool { get }
}
