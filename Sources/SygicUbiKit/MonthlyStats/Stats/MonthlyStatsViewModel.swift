import Foundation
import UIKit

// MARK: - MonthlyStatsViewModelError

public enum MonthlyStatsViewModelError: Error {
    case noCurrentCarForFiltering
}

// MARK: - MonthlyStatsViewModel

open class MonthlyStatsViewModel: MonthlyStatsViewModelType, InjectableType {
    public weak var delegate: MonthlyStatsViewModelDelegate?

    public var stats: MonthlyStatsDataType?
    public var currentDate: Date? {
            return stats?.date
        }

    public var currentMonthName: String? {
        guard let currentDate = self.currentDate else {
            return nil
        }

        return currentDate.monthAndYearFormatter(fullMonthName: true)
    }

    public var monthId: String?
    public var showCalendarIcon: Bool = true
    public var hasStatsToShow: Bool {
        guard let stats = stats else {
            return false
        }
        return stats.statistics.totalScore != 0
    }

    public private(set) var loading: Bool = false
    private lazy var repository: MonthlyStatsRepositoryType = container.resolveMonthlyStatsRepo()
    private lazy var vehicleRepository: VehicleProfileRepositoryType = container.resolveVehicleProfileRepo()

    private var _currentFilteringVehicle: VehicleProfileType?
    public var currentFilteringVehicle: VehicleProfileType? {
        get {
            if _currentFilteringVehicle != nil {
                return _currentFilteringVehicle
            }
            let storedVehicles = vehicleRepository.storedVehicles
            if storedVehicles.count > 0 {
                let selected = storedVehicles.first { $0.isSelectedForDriving == true }
                _currentFilteringVehicle = selected
            }
            return _currentFilteringVehicle
        }
        set {
            _currentFilteringVehicle = newValue
        }
    }

    public var hasMoreThanOneVehicle: Bool {
        vehicleRepository.activeVehicles.count > 1
    }

    public init(monthId: String?) {
        self.monthId = monthId
    }

    open func loadData(clearCache: Bool) {
        loading = true
        repository.loadData(for: monthId, vehicleId: currentFilteringVehicle?.publicId, clearCache: clearCache) { [weak self] result in
            guard let `self` = self else { return }
            self.loading = false
            switch result {
            case let .success(stats):
                self.stats = stats
                self.delegate?.viewModelDidUpdate(viewModel: self)
            case let .failure(error):
                self.delegate?.viewModelDidFail(viewModel: self, error: error)
            }
        }
    }

    public var overallCellViewModel: MonthlyStatsOverviewCellViewModelType {
        //Creating the corrent image
        let monthImageName: String = currentDate != nil ? "month\(String(describing: currentDate!.currentMonthNumber))Current" : "month\(String(describing: Date().currentMonthNumber))Current"
        let image: UIImage? = UIImage(named: monthImageName, in: .main, compatibleWith: nil)
        let monthScore: String = Format.scoreFormatted(value: stats?.statistics.totalScore ?? 0)
        let state: ReportScoreMonthComparision = stats?.statistics.monthComparison ?? .none
        let previousMonthScore: String = Format.scoreFormatted(value: stats?.statistics.previousTotalScore ?? 0)
        //Description String
        let firstString = NSAttributedString(string: state.description(for: nil) ?? "", attributes: [.font: UIFont.stylingFont(.bold, with: 16)])
        var descriptionString: NSAttributedString!
        if state == .best {
            descriptionString = NSAttributedString(string: "monthlyStats.overview.overall.postfixBest".localized)
        } else if state != .none {
            descriptionString = NSAttributedString(string: String(format: "monthlyStats.overview.overall.postfix".localized, previousMonthScore))
        } else {
            descriptionString = NSAttributedString(string: "")
        }
        let string = NSMutableAttributedString(attributedString: firstString)
        string.append(NSAttributedString(string: " "))
        string.append(descriptionString)

        return OverallCellViewModel(monthImage: image ?? UIImage(), monthScore: monthScore, description: string, state: state)
    }

    public var eventsCellViewModel: MonthlyStatsEventScoreCellViewModelType? {
        guard let stats = self.stats else {
            return nil
        }

        let statistics = stats.statistics
        //TODO: Server not sending state this yet
        let accelEvent: EventStatViewModel = EventStatViewModel(type: .acceleration, score: Format.scoreFormatted(value: statistics.acceleration.score),
                                                                state: statistics.acceleration.monthComparison)
        let breakingEvent: EventStatViewModel = EventStatViewModel(type: .braking, score: Format.scoreFormatted(value: statistics.braking.score),
                                                                   state: statistics.braking.monthComparison)
        let corneringEvent: EventStatViewModel = EventStatViewModel(type: .cornering, score: Format.scoreFormatted(value: statistics.cornering.score),
                                                                    state: statistics.cornering.monthComparison)
        let distractionEvent: EventStatViewModel = EventStatViewModel(type: .distraction, score: Format.scoreFormatted(value: statistics.distraction.score),
                                                                      state: .same)
        let speedingEvent: EventStatViewModel = EventStatViewModel(type: .speeding, score: String(Int(statistics.speeding.score)),
                                                                   state: statistics.speeding.monthComparison)

        var highligthedEvent: EventStatViewModel?
        var events: [EventStatViewModel] = [accelEvent, corneringEvent, distractionEvent, speedingEvent, breakingEvent]
        if let vehicle = self.currentFilteringVehicle, vehicle.vehicleType == .motorcycle {
            events.remove(at: 2)
        }
        let filtered = events.filter { $0.state != .none && $0.state != .same }
        if let first = filtered.first, let index = events.firstIndex(where: { $0 == first }) {
            events.remove(at: index)
            highligthedEvent = first
        }
        return EventsCellViewModel(events: events, highlightedEvent: highligthedEvent)
    }

    public var otherStatsCellViewModel: [MonthlyOtherStatType]? {
        guard let stats = self.stats else { return nil }

        let tripCount: MonthlyOtherStatType = MonthlyStatsOtherStat(value: String(Int(stats.statistics.tripCount)),
                                                                    description: "monthlyStats.overview.totalTripsTitle".localized)
        let distanceCount: MonthlyOtherStatType = MonthlyStatsOtherStat(value: String(format: "%i km", Int(stats.statistics.distanceDrivenKm)),
                                                                        description: "monthlyStats.overview.distanceTitle".localized)
        var otherStats = [tripCount, distanceCount]

        let undistractedCount: MonthlyOtherStatType = MonthlyStatsOtherStat(value: String(stats.statistics.undistractedTripCount),
                                                                            description: "monthlyStats.overview.undistractedTripsTitle".localized)

        if let filteringVehicle = currentFilteringVehicle, filteringVehicle.vehicleType != .motorcycle {
            otherStats.append(undistractedCount)
        } else if currentFilteringVehicle == nil {
            otherStats.append(undistractedCount)
        }

        return otherStats
    }

    public var badgesCellViewModel: [BadgeItemType]? {
        guard let stats = self.stats else { return nil }
        var badgesTypeArray: [BadgeItemType] = []
        stats.achievedBadges.forEach {
            let monthlyStatBadgeItem = MonthlyStatsBadge(id: $0.id,
                                                         imageLightUri: $0.image.lightUri,
                                                         imageDarkUri: $0.image.darkUri ?? "",
                                                         title: $0.title,
                                                         currentLevel: $0.level,
                                                         maximumLevel: 3) //TODO: Max level is requiered
            badgesTypeArray.append(monthlyStatBadgeItem)
        }
        return badgesTypeArray
    }

    public var distanceGraphCellViewModel: MonthlyStatsGraphDataSource? {
        guard let stats = self.stats else { return nil }
        let graphDataSet = stats.dailyGraphs.filter { $0.type == .dailyDistance }
        guard let graphData = graphDataSet.first else { return nil }
        let distanceDataSet = graphData.datasets.filter { $0.type == .distanceKm }
        guard let distanceData = distanceDataSet.first else { return nil }
        return MonthlyStatsGraphData(title: "monthlyStats.overview.dailyDistanceTitle".localized,
                                     subtitleFormat: "monthlyStats.overview.dailyDistanceSubtitle".localized,
                                     dataCollection: distanceData.data.map {Int($0)}, labels: graphData.labels, alternateDecreasebellow: nil)
    }

    public var scoreGrpahCellViewModel: MonthlyStatsGraphDataSource? {
        guard let stats = self.stats else { return nil }
        let graphDataSet = stats.dailyGraphs.filter { $0.type == .avgDailyTripScore }
        guard let graphData = graphDataSet.first else { return nil }
        let scoreDataSet = graphData.datasets.filter { $0.type == .totalScore }
        guard let scoreData = scoreDataSet.first else { return nil }
        var threshold: Int?
        if let monthlyStatsConfig = container.resolve(MonthlyStatsConfiguration.self) {
            threshold = monthlyStatsConfig.minScoreThreshold
        }
        return MonthlyStatsGraphData(title: "monthlyStats.overview.averageScoreTitle".localized,
                                     subtitleFormat: "monthlyStats.overview.averageScoreSubtitle".localized,
                                     dataCollection: scoreData.data.map {Int($0)}, labels: graphData.labels, alternateDecreasebellow: threshold)
    }

    public func rewardsCellViewModel(at index: Int) -> InfoItemType? {
        guard let stats = self.stats else { return nil }
        let contestsList = stats.awardedContests
        let contetst = contestsList[index]
        return MonthlyStatsRewardData(title: contetst.title,
                                      subtitle: nil,
                                      description: contetst.description,
                                      imageUri: contetst.image.lightUri,
                                      imageDarkUri: contetst.image.darkUri)
    }

    public func isInOffSeasson(for vehicleType: VehicleType) -> Bool {
        guard let offSeassonsData = ConfigurationModule.currentStoredConfiguration?.offSeassons else {
            return false
        }
        let currentMonth = Date().currentMonthNumber
        if let _ = offSeassonsData[vehicleType]?.first(where: { $0 == currentMonth}) {
            return true
        }
        return false
    }
}
