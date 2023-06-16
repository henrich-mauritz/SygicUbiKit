import Foundation

// MARK: - DiscountsModelProtocol

public protocol DiscountsModelProtocol {
    var discountCodesModel: DiscountCodesModelProtocol { get }
    var progressModel: DiscountProgressModelProtocol { get }
    var discountHowToModel: DiscountHowToModelProtocol { get }
    func loadDiscounts(_ completion: @escaping (Result<DiscountsOverviewProtocol, Error>) -> ())
    func claimDiscounts(_ completion: @escaping (Result<DiscountProtocol, Error>) -> ())
}

// MARK: - DiscountsOverviewProtocol

public protocol DiscountsOverviewProtocol {
    var currentChallenge: DiscountsChallenge? { get }
    var currentDiscount: DiscountProtocol { get }
    var totalAchievableDiscount: Double { get }
}

// MARK: - DiscountProtocol

public protocol DiscountProtocol {
    var isClaimable: Bool? { get }
    var discountAmount: Double? { get }
    var discountCode: String? { get }
    var validUntil: Date? { get }
}

// MARK: - DiscountsChallenge

public protocol DiscountsChallenge {
    var type: DiscountChallengeType { get }
    var overallScoreRequirement: Double { get }
    var overallScore: Double { get }
    var steps: [DiscountsChallengeStep] { get }
    var endExclusive: Date? { get }
    var startInclusive: Date { get }
}

// MARK: - DiscountsChallengeStep

public protocol DiscountsChallengeStep {
    var currentKm: Double { get }
    var goalKm: Double { get }
    var totalDiscount: Double { get }
    var discountIncrement: Double { get }
}

// MARK: - DiscountChallengeType

public enum DiscountChallengeType: String, Codable {
    case monthly
    case starting
    public enum Key: CodingKey { case rawValue }
    public enum CodingError: Error { case unknownValue }
}
