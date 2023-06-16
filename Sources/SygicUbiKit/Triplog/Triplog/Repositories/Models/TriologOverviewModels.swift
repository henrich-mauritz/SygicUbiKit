import Foundation

// MARK: - NetworkOverviewData

struct NetworkOverviewData: Codable {
    struct ContainerData: Codable {
        var challengeInfo: ChallengeInfo?
        var overallInfo: OverallInfo?
        var evaluationPeriodInfo: EvaluationPeriodInfo
        var tiles: [NetworkTilesData]?
    }

    struct ChallengeInfo: Codable {
        var totalScore: Double
        var tripCount: Int
        var distanceDrivenKm: Double
        var startDateInclusive: Date
        var endDateExclusive: Date
    }

    struct OverallInfo: Codable {
        var totalScore: Double
        var tripCount: Int
        var distanceDrivenKm: Double
    }

    struct EvaluationPeriodInfo: Codable {
        var reachedDiscountPercentage: Int
        var totalScore: Double
        var tripCount: Int
        var distanceDrivenKm: Double
        var startDateInclusive: Date
        var endDateExclusive: Date
    }

    var data: ContainerData
}

// MARK: TriplogOverviewDataType

extension NetworkOverviewData: TriplogOverviewDataType {
    var score: Double { data.evaluationPeriodInfo.totalScore }
    var kilometers: Double { data.evaluationPeriodInfo.distanceDrivenKm }
    var discount: Int { Int(data.evaluationPeriodInfo.reachedDiscountPercentage) }
    var overallTripCount: Int { data.overallInfo?.tripCount ?? 0 }
    var evaluatedPeriodTripCount: Int { data.evaluationPeriodInfo.tripCount }
    var cards: [TriplogOverviewCardDataType] { data.tiles ?? [NetworkTilesData]() }
}

// MARK: - NetworkTilesData

struct NetworkTilesData: Codable {
    var type: String
    var year: Int?
    var month: Int?
    var totalScore: Double?
    var distanceDrivenKm: Double
    var reachedDiscountPercentage: Int?
    var startDateInclusive: Date?
    var endDateExclusive: Date?
    var detailId: String?
    var children: [NetworkTilesData]?
}

// MARK: TriplogOverviewCardDataType

extension NetworkTilesData: TriplogOverviewCardDataType {
    var cardType: TileType { TileType(rawValue: type)! }
    var monthNumber: Int? { month }
    var yearNumber: Int? { year }
    var score: Double { totalScore ?? 0 }
    var kilometers: Double { distanceDrivenKm }
    var discountPercentage: Int? { reachedDiscountPercentage }
    var cardId: String? { detailId }
    var startPeriod: Date? { startDateInclusive }
    var endPeriod: Date? { endDateExclusive }
    var childrenCards: [TriplogOverviewCardDataType]? { children }
}
