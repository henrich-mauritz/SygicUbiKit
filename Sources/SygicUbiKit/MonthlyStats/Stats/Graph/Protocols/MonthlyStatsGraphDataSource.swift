import Foundation
import UIKit

// MARK: - MonthlyStatDayBarType

public protocol MonthlyStatDayBarType {
    var value: Int { set get }
    var isMax: Bool { set get }
    var barColor: UIColor { set get }
}

// MARK: - MonthlyStatsGraphDataSource

public protocol MonthlyStatsGraphDataSource {
    //TODO: Implement
    var title: String { get }
    var subtitle: String? { get }
    var numberOfDays: Int { get }
    func barTypeForDay(at index: Int) -> MonthlyStatDayBarType
    func subTitleForWeek(at index: Int) -> String
}
