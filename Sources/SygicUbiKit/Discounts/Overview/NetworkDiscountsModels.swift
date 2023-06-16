import Foundation

// MARK: - NetworkDiscounts

public struct NetworkDiscounts: Codable {
    public struct Container: Codable {
        public struct CurrentChallenge: Codable, DiscountsChallenge {
            public struct ChallengeStep: Codable, DiscountsChallengeStep {
                public var currentKm: Double
                public var goalKm: Double
                public var totalDiscount: Double
                public var discountIncrement: Double
            }

            public var type: DiscountChallengeType
            public var overallScoreRequirement: Double
            public var challengeSteps: [ChallengeStep]
            public var overallScore: Double
            public var endExclusive: Date?
            public var startInclusive: Date
        }

        public var currentChallenge: CurrentChallenge?
        public var currentDiscount: NetworkDiscount
        public var totalAchievableDiscount: Double
    }

    var data: Container
}

// MARK: DiscountsOverviewProtocol

extension NetworkDiscounts: DiscountsOverviewProtocol {
    public var currentDiscount: DiscountProtocol { data.currentDiscount }
    public var currentChallenge: DiscountsChallenge? { data.currentChallenge}
    public var totalAchievableDiscount: Double { data.totalAchievableDiscount }
}

public extension NetworkDiscounts.Container.CurrentChallenge {
    var steps: [DiscountsChallengeStep] { challengeSteps }
}

// MARK: - NetworkDiscount

public struct NetworkDiscount: Codable, DiscountProtocol {
    public var discountCode: String?
    public var validUntil: Date?
    public var discountAmount: Double?
    public var isClaimable: Bool?
}

// MARK: - NetworkClaimData

struct NetworkClaimData: Codable {
    var data: NetworkDiscount
}

// MARK: DiscountProtocol

extension NetworkClaimData: DiscountProtocol {
    var discountCode: String? { data.discountCode }
    var validUntil: Date? { data.validUntil }
    var discountAmount: Double? { data.discountAmount }
    var isClaimable: Bool? { data.isClaimable }
}
