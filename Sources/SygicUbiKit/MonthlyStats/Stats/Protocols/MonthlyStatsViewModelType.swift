import Foundation

// MARK: - MonthlyStatsViewModelDelegate

public protocol MonthlyStatsViewModelDelegate: AnyObject {
    func viewModelDidUpdate(viewModel: MonthlyStatsViewModelType)
    func viewModelDidFail(viewModel: MonthlyStatsViewModelType, error: Error)
}

// MARK: - MonthlyStatsViewModelType

public protocol MonthlyStatsViewModelType {
    var stats: MonthlyStatsDataType? { set get }
    var delegate: MonthlyStatsViewModelDelegate? { get set }
    var currentDate: Date? { get }
    var showCalendarIcon: Bool { get set }
    var loading: Bool { get }
    var currentMonthName: String? { get }
    var hasStatsToShow: Bool { get }
    var currentFilteringVehicle: VehicleProfileType? { get set }
    var hasMoreThanOneVehicle: Bool { get }
    // cell viewModels
    var overallCellViewModel: MonthlyStatsOverviewCellViewModelType { get }
    var eventsCellViewModel: MonthlyStatsEventScoreCellViewModelType? { get }
    var otherStatsCellViewModel: [MonthlyOtherStatType]? { get }
    var badgesCellViewModel: [BadgeItemType]? { get }
    var distanceGraphCellViewModel: MonthlyStatsGraphDataSource? { get }
    var scoreGrpahCellViewModel: MonthlyStatsGraphDataSource? { get }
    func isInOffSeasson(for vehicleType: VehicleType) -> Bool
    func loadData(clearCache: Bool)
    func rewardsCellViewModel(at index: Int) -> InfoItemType?
}
