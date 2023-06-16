import Foundation
import Swinject

// MARK: - TriplogMonthViewModel

public class TriplogMonthViewModel: TriplogCardViewModelProtocol, InjectableType {
    //MARK: - Properties

    public weak var delegate: TriplogViewModelDelegate?
    public private(set) var categorizedTrips: [TriplogDateSectionTripModel] = []
    public var isPeriodOverView: Bool = false
    public private(set) var loading: Bool = false

    private var allTrips = [TriplogTripCardViewModelProtocol]()
    private var filteredTrips = [TriplogTripCardViewModelProtocol]()
    private var notificationsObservers = [NSObjectProtocol]()
    private lazy var repository: TriplogMonthlyRepositoryType = container.resolveTriplogMonthlyRepo()

    private var currentPage: Int = 1
    public var model: TriplogOverviewCardDataType? {
        didSet {
            guard model != nil else { return }
            self.organizeCategorizedTrips()
        }
    }

    public var drivingScoreText: String {
        let score = model?.score ?? 0
        return Format.scoreFormatted(value: score)
    }

    public var drivingScoreDescription: String { "triplog.monthOverview.scoreTitle".localized }
    public var kilometersDrivenText: String {
        let kilometers: Double = model?.kilometers ?? 0
        return "\(NumberFormatter().distanceTraveledFormatted(value: kilometers)) km"
    }

    public var kilometersDrivenDescription: String { "triplog.monthOverview.distanceTitle".localized }
    public var monthTitle: String {
        guard let model = model else { return "" }
        var dateComponents = DateComponents()
        dateComponents.month = model.monthNumber
        dateComponents.year = model.yearNumber
        guard let calendar = NSCalendar(identifier: .gregorian), let monthDate = calendar.date(from: dateComponents) else { return "" }
        if isPeriodOverView {
            return monthYearFormatter.string(from: monthDate)
        } else {
            return monthFormatter.string(from: monthDate)
        }
    }

    public var trips: [TriplogTripCardViewModelProtocol] {
        allTrips
    }

    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        if let preferredLanguage = CommonConfigurator.shared.configuration.preferredLanguage {
            formatter.locale = Locale(identifier: preferredLanguage)
        }
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        return formatter
    }()

    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        if let preferredLanguage = CommonConfigurator.shared.configuration.preferredLanguage {
            formatter.locale = Locale(identifier: preferredLanguage)
        }
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter
    }()

    public var listingType: TriplogMonthlyListingType = TriplogMonthlyListingType(rawValue: UserDefaults.standard.string(forKey: "MonthlyOverviewLayout") ?? TriplogMonthlyListingType.list.rawValue) ?? .list {
        didSet {
            UserDefaults.standard.setValue(listingType.rawValue, forKey: "MonthlyOverviewLayout")
        }
    }

    public var currentFilteringVehicle: VehicleProfileType?

    public var isCurrentMonth: Bool {
        guard let model = model else { return false }
        var dateComponents = DateComponents()
        dateComponents.month = model.monthNumber
        dateComponents.year = model.yearNumber

        let todayComponents = Calendar.current.dateComponents([.month, .year], from: Date())

        return dateComponents.month == todayComponents.month && dateComponents.year == todayComponents.year
    }

    //MARK: - Lifecycle

    init(with model: TriplogOverviewCardDataType) {
        self.model = model
        notificationsObservers.append(NotificationCenter.default.addObserver(forName: .newTripScoreNotification, object: nil, queue: .main) { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.viewModelUpdated(weakSelf)
        })
        observeNetworkChange()
    }

    public convenience init(withCardModel cardModel: TriplogOverviewCardDataType) {
        self.init(with: cardModel)
    }

    deinit {
        notificationsObservers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }

    //MARK: - Fetching

    public func reloadTrips(purgeData: Bool = true, completion: @escaping ((_ finished: Bool) -> Void)) {
        guard let detailId = self.model?.detailId else { return }
        if purgeData {
            repository.purgueData(for: detailId)
        }
        let requestData = ApiRouterTriplog.TripsRequestData(detailId: detailId, vehicleId: currentFilteringVehicle?.publicId)
        loadTrips(with: requestData) {[weak self] result in
            switch result {
            case let .success(tripsData):
                self?.allTrips.removeAll()
                self?.updateTrips(tripsData.trips)

            case let .failure(error):
                self?.allTrips = []
                self?.filteredTrips = []
                self?.categorizedTrips = []
                self?.delegate?.viewModelDidFail(with: error)
            }
            completion(true)
        }
    }

    public func loadMoreTrips() {
        let nextPage = currentPage + 1
        let pCount = pagesCount()
        guard nextPage <= pCount, let detailId = self.model?.detailId else { return }
        var requestData = ApiRouterTriplog.TripsRequestData(detailId: detailId, vehicleId: currentFilteringVehicle?.publicId)
        requestData.page = nextPage
        if self.loading == false {
            loadTrips(with: requestData) {[weak self] result in
                switch result {
                case let .success(tripsData):
                    self?.updateTrips(tripsData.trips)
                default:
                    break
                }
            }
        }
    }

    //MARK: - Utils

    public func tripDetailViewModel(for trip: TriplogTripCardViewModelProtocol) -> TripDetailViewModelProtocol? {
        guard let tripData = trip.data else { return nil }
        let detailViewModel = container.resolve(TripDetailViewModelProtocol.self)
        detailViewModel?.monthData = tripData
        return detailViewModel
    }

    private func pagesCount() -> Int {
        guard let detailId = self.model?.detailId else {
            return 0
        }
        return repository.pageCount(forDataWith: detailId)
    }

    private func updateTrips(_ tripModels: [TriplogTripDataType]) {
        let trips: [TriplogTripCardViewModelProtocol] = tripModels.compactMap {
            guard var viewModel = container.resolve(TriplogTripCardViewModelProtocol.self) else { return nil }
            viewModel.data = $0
            return viewModel
        }
        allTrips.append(contentsOf: trips)
        self.organizeCategorizedTrips()
        delegate?.viewModelUpdated(self)
    }

    private func organizeCategorizedTrips() {
        var tempCats: [TriplogDateSectionTripModel] = []
        let normalizedDates = trips.map { trip -> Date? in
            trip.normalizedDate
        }.compactMap { $0 }

        let unique = Array(Set(normalizedDates))

        for date in unique {
            let filtered = trips.filter {
                guard let tripDate = $0.normalizedDate else {
                    return false
                }
                return tripDate.compare(date) == .orderedSame
            }
            let sectionModel = TriplogDateSectionTripModel(sectionTrips: filtered, sectionDate: date)
            tempCats.append(sectionModel)
        }

        tempCats.sort { m1, m2 -> Bool in
            m1.sectionDate.compare(m2.sectionDate) == .orderedDescending
        }
        categorizedTrips = tempCats
        print(categorizedTrips)
    }
}

//MARK: - Rechability

extension TriplogMonthViewModel {
    func observeNetworkChange() {
        notificationsObservers.append(NotificationCenter.default.addObserver(forName: .flagsChanged,
                                                                             object: nil,
                                                                             queue: nil) {[weak self] _ in
                                                DispatchQueue.main.async {
                                                    switch ReachabilityManager.shared.status {
                                                    case .wwan, .wifi:
                                                        self?.reloadTrips(completion: { _ in })
                                                    default:
                                                        print("no connection reached")
                                                    }
                                                }
        })
    }
}

//MARK: - Data fetching

fileprivate extension TriplogMonthViewModel {
    func loadTrips(with requestData: ApiRouterTriplog.TripsRequestData, completion: @escaping (Result<TriplogTripsDataType, Error>) -> ()) {
        loading = true
        repository.fetchMonthlyData(with: requestData) {[weak self] result in
            switch result {
            case .success(_):
                self?.currentPage = requestData.page
            default:
                print("there was some error fetchign data")
            }
            completion(result)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self?.loading = false
            }
        }
    }
}
