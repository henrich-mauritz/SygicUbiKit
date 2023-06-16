import UIKit

// MARK: - DiscountProgressModelProtocol

public protocol DiscountProgressModelProtocol {
    func loadProgressData(_ completion: @escaping (Result<DiscountProgressDataProtocol, Error>) -> ())
}

// MARK: - DiscountProgressDataProtocol

public protocol DiscountProgressDataProtocol {
    var items: [DiscountProgressChallange] { get }
}

// MARK: - DiscountProgressChallange

public protocol DiscountProgressChallange {
    var type: DiscountChallengeType { get }
    var items: [ChallangeSteps]? { get }
    var date: Date? { get }
}

// MARK: - ChallangeSteps

public protocol ChallangeSteps {
    var state: DiscountProgressType { get }
    var discountAmount: Double { get }
}

// MARK: - DiscountProgressType

public enum DiscountProgressType: String, Codable {
    case achieved
    case missed
    case canBeAchieved
    case offSeason

    public enum Key: CodingKey {
        case rawValue
    }

    public enum CodingError: Error {
        case unknownValue
    }
}

// MARK: - DiscountProgressViewProtocol

public protocol DiscountProgressViewProtocol where Self: UIView {
    var viewModel: DiscountProgressViewModelProtocol? { get set }
}

// MARK: - DiscountProgressViewModelProtocol

public protocol DiscountProgressViewModelProtocol {
    var start: DiscountProgressType { get }
    var items: [DiscountProgressChallange] { get }
    var loading: Bool { get }
    var delegate: DiscountProgressViewModelDelegate? { get set }
    var highlitedItemIndex: Int { get }
    var currentFilteringVehicle: VehicleProfileType { get set }
    var hasMoreThanOneVehicle: Bool { get }
    func reloadData()
}
