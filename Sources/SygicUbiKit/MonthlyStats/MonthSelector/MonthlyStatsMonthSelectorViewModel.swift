import Foundation

// MARK: - MonthSelectorItemDatatype

public protocol MonthSelectorItemDatatype {
    var title: String { get }
    var score: String? { get }
    var state: ReportScoreMonthComparision? { get }
}

// MARK: - MonthSelectorItem

public struct MonthSelectorItem: MonthSelectorItemDatatype {
    public var title: String { monthItem.date.monthAndYearFormatter(fullMonthName: true) }
    public var score: String? {
        guard let score = monthItem.totalScore else {
            return nil
        }
        return String(Int(score))
    }

    public var state: ReportScoreMonthComparision? { monthItem.monthComparison }
    public var monthItem: NetworkMonthlyStatMonthScore.NetworkMonthStatScore
    public init(monthItem: NetworkMonthlyStatMonthScore.NetworkMonthStatScore) {
        self.monthItem = monthItem
    }
}

// MARK: - MonthlyStatsMonthSelectorViewModelDelegate

protocol MonthlyStatsMonthSelectorViewModelDelegate: AnyObject {
    func viewModelDidUpdate(viewModel: MonthlyStatsMonthSelectorViewModel)
    func viewModelDidFail(viewModel: MonthlyStatsMonthSelectorViewModel, error: Error)
}

// MARK: - MonthlyStatsMonthSelectorViewModel

class MonthlyStatsMonthSelectorViewModel: InjectableType {
    var items: [MonthSelectorItem]?
    var loading: Bool = false
    weak var delegate: MonthlyStatsMonthSelectorViewModelDelegate?

    private lazy var repository: MonthlyStatsRepositoryType = container.resolveMonthlyStatsRepo()
    public var currentFilteringVehicle: VehicleProfileType?
    public var hasMoreThanOneVehicle: Bool {
        let vehicleRepo: VehicleProfileRepositoryType = container.resolveVehicleProfileRepo()
        return vehicleRepo.storedVehicles.count > 0
    }

    init(with vehicle: VehicleProfileType?) {
        currentFilteringVehicle = vehicle
    }

    var numberOfItems: Int {
        guard let items = items else { return 0 }
        return items.count
    }

    func loadData(clearCache: Bool) {
        loading = true
        repository.loadPreviousMonths(clearCache: clearCache, vehicleId: currentFilteringVehicle?.publicId) { [weak self] result in
            guard let self = self else { return }
            self.loading = false
            switch result {
            case let .success(monthItems):
                self.items = monthItems
                self.delegate?.viewModelDidUpdate(viewModel: self)
            case let .failure(error):
                self.delegate?.viewModelDidFail(viewModel: self, error: error)
            }
        }
    }
}
