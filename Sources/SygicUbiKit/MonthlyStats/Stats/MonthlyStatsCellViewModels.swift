import Foundation
import UIKit

// MARK: - OverallCellViewModel

//MARK: - CellViewModels

struct OverallCellViewModel: MonthlyStatsOverviewCellViewModelType {
    var monthImage: UIImage
    var monthScore: String
    var description: NSAttributedString
    var state: ReportScoreMonthComparision
}

// MARK: - EventsCellViewModel

struct EventsCellViewModel: MonthlyStatsEventScoreCellViewModelType {
    var events: [EventStatViewModel]
    var highlightedEvent: EventStatViewModel?
    /// Creates a cell viewModel for th events cell
    /// - Parameters:
    ///   - events: the events in the array list. This list shall not include the highlightefEvent
    ///   - highlightedEvent: HighligthedEvent, this is the first event of the cell
    init(events: [EventStatViewModel], highlightedEvent: EventStatViewModel?) {
        self.events = events.sorted(by: { $0.type.eventPriority() > $1.type.eventPriority() })
        self.highlightedEvent = highlightedEvent
    }
}

// MARK: - MonthlyStatsOtherStat

struct MonthlyStatsOtherStat: MonthlyOtherStatType {
    var value: String
    var description: String
}

// MARK: - MonthlyStatsRewardData

struct MonthlyStatsRewardData: InfoItemType {
    var title: String
    var subtitle: String?
    var description: String?
    var imageUri: String
    var imageDarkUri: String?
}

// MARK: - MonthlyStatsBadge

struct MonthlyStatsBadge: BadgeItemType {
    var id: String
    var imageLightUri: String
    var imageDarkUri: String
    var title: String
    var currentLevel: Int
    var maximumLevel: Int
}

// MARK: - MonthlyStatsGraphData

struct MonthlyStatsGraphData: MonthlyStatsGraphDataSource {
    var title: String
    var subtitle: String?
    var numberOfDays: Int { bars.count }

    private var bars: [MonthlyStatDayBarType] = []
    private let labels: [Date]

    private let dateFormater: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.M."
        if Locale.current.identifier == "sl_SI" { //this is nuts!
            formatter.dateFormat = "d. M."
        }
        return formatter
    }()

    init(title: String, subtitleFormat: String, dataCollection: [Int], labels: [Date], alternateDecreasebellow threshold: Int?) {
        self.labels = labels
        self.title = title
        //need to normalize to 100
        let maxVal = dataCollection.max() ?? 100

        dataCollection.forEach {
            let normalizedVal = MonthlyStatsGraphData.nomralize(val: $0, max: maxVal, min: 0)
            var intVal = Int(normalizedVal * 100)
            if intVal == 0 && $0 != 0 { //avoid big gaps so there is a minimun to draw
                intVal = 1
            }
            let bar = MonthlyStatDayBarData(value: intVal, isMax: ($0 == maxVal) && $0 != 0)
            bars.append(bar)
            if let threshold = threshold { //Maybe shall be done using thresholds.. but API not ready yet.
                if $0 < threshold {
                    bar.barColor = Styling.negativeSecondary
                }
            }
        }
        subtitle = String(format: subtitleFormat, maxVal)
    }

    func barTypeForDay(at index: Int) -> MonthlyStatDayBarType {
        return bars[index]
    }

    func subTitleForWeek(at index: Int) -> String {
        var labelIndex = index * 10
        if labelIndex > 0 {
            labelIndex -= 1
        }
        var date: Date!
        if labelIndex < labels.count - 1 {
            date = labels[labelIndex]
        } else {
            date = labels.last
        }

        return dateFormater.string(from: date)
    }

    private static func nomralize(val: Int, max: Int, min: Int) -> Double {
        let dividend = Double(max - min)
        guard dividend != 0 else { return 0 }
        return Double(val - min) / Double(max - min)
    }
}

// MARK: - MonthlyStatDayBarData

class MonthlyStatDayBarData: MonthlyStatDayBarType {
    var value: Int
    var isMax: Bool
    var barColor: UIColor

    init(value: Int, isMax: Bool) {
        self.value = value
        self.isMax = isMax
        barColor = Styling.positivePrimary
    }
}
