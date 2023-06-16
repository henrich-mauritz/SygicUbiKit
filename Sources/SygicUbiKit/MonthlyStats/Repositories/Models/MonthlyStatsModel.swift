import Foundation
import UIKit

// MARK: - MonthlyStatsDataType

//MARK: - Badge Item

public protocol MonthlyStatsDataType {
    var id: String { get }
    var date: Date { get }
    var statistics: NetworkMonthlyUserTripStats { get }
    var awardedContests: [NetworkMonthlyStatsAwaredContest] { get }
    var achievedBadges: [NetworkMonthlyStatsAchievedBadge] { get }
    var dailyGraphs: [NetworMonthlyStatsDailyGraph] { get }
}

// MARK: - NetworkMonthlyStatsData

public struct NetworkMonthlyStatsData: MonthlyStatsDataType, Codable {
    struct Container: Codable {
        var id: String
        var date: Date
        var statistics: NetworkMonthlyUserTripStats
        var awardedContests: [NetworkMonthlyStatsAwaredContest]
        var achievedBadges: [NetworkMonthlyStatsAchievedBadge]
        var dailyGraphs: [NetworMonthlyStatsDailyGraph]
    }

    var data: Container
    public var id: String { data.id }
    public var date: Date { data.date }
    public var statistics: NetworkMonthlyUserTripStats { data.statistics }
    public var awardedContests: [NetworkMonthlyStatsAwaredContest] { data.awardedContests }
    public var achievedBadges: [NetworkMonthlyStatsAchievedBadge] { data.achievedBadges }
    public var dailyGraphs: [NetworMonthlyStatsDailyGraph] { data.dailyGraphs }
}

// MARK: - NetworkMonthlyUserTripStats

public struct NetworkMonthlyUserTripStats: Codable {
    public struct EventsScoreComparision: Codable {
        let score: Double
        let monthComparison: ReportScoreMonthComparision
    }

    var totalScore: Double
    var previousTotalScore: Double?
    var monthComparison: ReportScoreMonthComparision?
    var tripCount: Int
    var undistractedTripCount: Int
    var distanceDrivenKm: Double
    var acceleration: EventsScoreComparision
    var braking: EventsScoreComparision
    var cornering: EventsScoreComparision
    var distraction: EventsScoreComparision
    var speeding: EventsScoreComparision
}

// MARK: - NetworkMonthlyStatsAwaredContest

public struct NetworkMonthlyStatsAwaredContest: Codable {
    var id: String
    var image: NetworkStatsImage
    var title: String
    var subtitle: String?
    var description: String
}

// MARK: - NetworkMonthlyStatsAchievedBadge

public struct NetworkMonthlyStatsAchievedBadge: Codable {
    var id: String
    var image: NetworkStatsImage
    var title: String
    var level: Int
}

// MARK: - NetworkStatsImage

public struct NetworkStatsImage: Codable {
    var lightUri: String
    var darkUri: String?
}

// MARK: - NetworMonthlyStatsDailyGraph

public struct NetworMonthlyStatsDailyGraph: Codable {
    public enum GraphType: String, Codable {
        case avgDailyTripScore
        case dailyDistance
    }

    public struct GraphDataSet: Codable {
        public enum DatasetType: String, Codable {
            case totalScore
            case distanceKm
        }

        public var type: DatasetType
        public var data: [Double]
    }

    public var type: GraphType
    public var datasets: [GraphDataSet]
    public var labels: [Date]
}

// MARK: - ReportScoreMonthComparision

public enum ReportScoreMonthComparision: String, Codable, InjectableType {
    case none
    case same
    case decreased
    case decreasedSignificantly
    case increased
    case increasedSignificantly
    case best

    var color: UIColor {
        switch self {
        case .decreasedSignificantly, .decreased:
            return .negativePrimary
        case .same, .none:
            return .backgroundTertiary
        default:
            return .positivePrimary
        }
    }

    func description(for eventType: EventType?) -> String? {
        guard let eventType = eventType else {
            // overall description
            switch self {
            case .same:
                return "monthlyStats.overview.overall.same".localized
            case .decreased:
                return "monthlyStats.overview.overall.decreaseLow".localized
            case .decreasedSignificantly:
                return "monthlyStats.overview.overall.decreaseHigh".localized
            case .increased:
                return "monthlyStats.overview.overall.increaseLow".localized
            case .increasedSignificantly:
                return "monthlyStats.overview.overall.increaseHigh".localized
            case .best:
                return "monthlyStats.overview.overall.best".localized
            case .none:
                return nil
            }
        }
        switch eventType {
        case .braking:
            switch self {
            case .decreased:
                return "monthlyStats.overview.braking.decreaseLow".localized
            case .decreasedSignificantly:
                return "monthlyStats.overview.braking.decreaseHigh".localized
            case .increased:
                return "monthlyStats.overview.braking.increaseLow".localized
            case .increasedSignificantly:
                return "monthlyStats.overview.braking.increaseHigh".localized
            default:
                return nil
            }
        case .acceleration:
            switch self {
            case .decreased:
                return "monthlyStats.overview.acceleration.decreaseLow".localized
            case .decreasedSignificantly:
                return "monthlyStats.overview.acceleration.decreaseHigh".localized
            case .increased:
                return "monthlyStats.overview.acceleration.increaseLow".localized
            case .increasedSignificantly:
                return "monthlyStats.overview.acceleration.increaseHigh".localized
            default:
                return nil
            }
        case .cornering:
            switch self {
            case .decreased:
                return "monthlyStats.overview.cornering.decreaseLow".localized
            case .decreasedSignificantly:
                return "monthlyStats.overview.cornering.decreaseHigh".localized
            case .increased:
                return "monthlyStats.overview.cornering.increaseLow".localized
            case .increasedSignificantly:
                return "monthlyStats.overview.cornering.increaseHigh".localized
            default:
                return nil
            }
        case .distraction:
            switch self {
            case .decreased:
                return "monthlyStats.overview.distraction.decreaseLow".localized
            case .decreasedSignificantly:
                return "monthlyStats.overview.distraction.decreaseHigh".localized
            case .increased:
                return "monthlyStats.overview.distraction.increaseLow".localized
            case .increasedSignificantly:
                return "monthlyStats.overview.distraction.increaseHigh".localized
            default:
                return nil
            }
        case .speeding:
            switch self {
            case .decreased:
                return "monthlyStats.overview.speeding.decreaseLow".localized
            case .decreasedSignificantly:
                return "monthlyStats.overview.speeding.decreaseHigh".localized
            case .increased:
                return "monthlyStats.overview.speeding.increaseLow".localized
            case .increasedSignificantly:
                return "monthlyStats.overview.speeding.increaseHigh".localized
            default:
                return nil
            }
        }
    }

    func clickableText(for eventType: EventType?) -> NSAttributedString? {
        guard let eventType = eventType, let configuration = container.resolve(MonthlyStatsConfiguration.self),
                let tuple = configuration.textableURL(for: eventType, comparision: self) else {
            return nil
        }
        let attributedString = NSMutableAttributedString(string: tuple.fullText, attributes: [.font: UIFont.stylingFont(.regular, with: 16), .foregroundColor: Styling.foregroundPrimary])
        let fullTextRange = NSRange(location: 0, length: tuple.fullText.count)
        if NSIntersectionRange(fullTextRange, tuple.range).length > 0 {
            attributedString.addAttribute(.link, value: tuple.url.absoluteString, range: tuple.range)
        }
        return attributedString
    }
}

// MARK: - NetworkMonthlyStatMonthScore

public struct NetworkMonthlyStatMonthScore: Codable {
    public struct NetworkMonthStatScore: Codable {
        var id: String
        var date: Date
        var totalScore: Double?
        var monthComparison: ReportScoreMonthComparision?
    }

    public struct Container: Codable {
        public var months: [NetworkMonthStatScore]
    }

    var data: Container
    public var monthList: [NetworkMonthStatScore] {
        data.months
    }
}

// MARK: - EventType

public enum EventType: String, Codable {
    case braking
    case cornering
    case acceleration
    case distraction
    case speeding

    public enum Key: CodingKey {
        case rawValue
    }

    public enum CodingError: Error {
        case unknownValue
    }

    public func formattedScoreString() -> String {
        switch self {
        case .braking:
            return "monthlyStats.overview.braking.title".localized
        case .cornering:
            return "monthlyStats.overview.cornering.title".localized
        case .acceleration:
            return "monthlyStats.overview.acceleration.title".localized
        case .distraction:
            return "monthlyStats.overview.distraction.title".localized
        case .speeding:
            return "monthlyStats.overview.speeding.title".localized
        }
    }
    
    public func formattedString() -> String {
        switch self {
        case .braking:
            return "triplog.tripDetailScore.braking".localized
        case .cornering:
            return "triplog.tripDetailScore.cornering".localized
        case .acceleration:
            return "triplog.tripDetailScore.acceleration".localized
        case .distraction:
            return "triplog.tripDetailScore.distraciton".localized
        case .speeding:
            return "triplog.tripDetailScore.speed".localized
        }
    }
    
    public func formatedEventDetailString() -> String {
        if self == .speeding {
            return "triplog.tripDetailScore.speeding".localized
        } else {
            return formattedString()
        }
    }

    public func eventColor(with severity: SevernityLevel? = nil) -> UIColor {
        switch self {
        case .braking:
            return UIColor.braking
        case .cornering:
            return UIColor.cornering
        case .acceleration:
            return UIColor.accelerating
        case .distraction:
            return UIColor.distraction
        case .speeding:
            return severity?.toColor() ?? UIColor.speeding
        }
    }
    
    public func eventPriority() -> Float {
        switch self {
        case .braking:
            return 6
        case .cornering:
            return 2
        case .acceleration:
            return 4
        case .distraction:
            return 10
        case .speeding:
            return 8
        }
    }
}
