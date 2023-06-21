import Foundation
import UIKit

public class TriplogOverviewCardViewModel: TriplogOverviewCardViewModelProtocol {
    public var model: TriplogOverviewCardDataType?

    public var image: UIImage? {
        monthImage(for: model?.monthNumber ?? 0)
    }

    public var score: String {
        switch model?.cardType {
            case .archive:
                return ""
            case .archivedPeriod:
                let score = model?.discountPercentage ?? 0
                return "\(score) %"
            default:
                let score = model?.score ?? 0
                return Format.scoreFormatted(value: score)
        }
    }

    public var kilometers: String {
        var kilometers: Double = 0
        if let model = model {
            kilometers = model.kilometers
        }
        return "\(NumberFormatter().distanceTraveledFormatted(value: kilometers)) km"
    }

    public var cardType: TileType? { return self.model?.cardType }

    public var title: String {
        guard let model = model else { return "" }
        switch model.cardType {
        case .archive:
            return "triplog.overview.cardArchiveTitle".localized
        case .tripsForMonth:
            guard let month = model.monthNumber, let year = model.yearNumber else { return "" }
            var dateComponents = DateComponents()
            dateComponents.month = month
            dateComponents.year = year
            guard let calendar = NSCalendar(identifier: .gregorian), let monthDate = calendar.date(from: dateComponents) else { return "" }
            return monthFormatter.string(from: monthDate)
        case .archivedPeriod:
            guard let start = model.startPeriod, let end = model.endPeriod else { return "" }
            return start.periodForEndFormatter(end: end)
        case .tripsForDateRange:
            guard let end = model.endPeriod else { return "" }
            if model.cardId == nil { // migrated period
                return String(format: "triplog.overview.dateBefore".localized, end.monthAndYearFormatter())
            }
            return model.startPeriod?.periodForEndFormatter(end: end) ?? ""
        }
    }

    public var isLongerPeriodCard: Bool {
        switch model?.cardType {
        case .tripsForDateRange, .archivedPeriod:
            return true
        default:
            return false
        }
    }

    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        if let preferredLanguage = CommonConfigurator.shared.configuration.preferredLanguage {
            formatter.locale = Locale(identifier: preferredLanguage)
        }
        formatter.setLocalizedDateFormatFromTemplate("MMM yyyy")
        return formatter
    }()

    private let currentMonth: Int = {
        let calendar = Calendar.current
        let date = Date()
        return calendar.component(.month, from: date)
    }()

    private func monthImage(for month: Int) -> UIImage? {
        switch model?.cardType {
        case .archive:
            return UIImage(named: "archive", in: .module, compatibleWith: nil)
        case .tripsForDateRange, .archivedPeriod:
            return UIImage(named: "period", in: .module, compatibleWith: nil)
        default:
            guard month <= 12 && month >= 1 else { return UIImage(named: "month8", in: .main, compatibleWith: nil) }
            var monthAssetName = "month\(month)"
            if month == currentMonth {
                monthAssetName.append("Current")
            }
            return UIImage(named: monthAssetName, in: .main, compatibleWith: nil)
        }
    }

    public func canBeClicked() -> Bool {
        model?.cardId != nil || model?.cardType == .archive
    }
}
