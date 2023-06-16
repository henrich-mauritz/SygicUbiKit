import Foundation
import Swinject

// MARK: - TriplogArchiveViewModel

//MARK: - Archive ViewModel

public class TriplogArchiveViewModel: TriplogOverviewViewModelProtocol, InjectableType {
    public var visualsConfig: TriplogOverviewViewVisualsConfigurable = TriplogDefaultOverviewVisuals()
    public weak var delegate: TriplogViewModelDelegate?
    public var drivingScoreText: String = ""
    public var drivingScoreDescription: String = ""
    public var kilometersDrivenText: String
    public var kilometersDrivenDescription: String = "triplog.tripArchive.distanceTitle".localized
    public var loading: Bool = false
    public var timeoutScreen: Bool = false
    public var hasData: Bool = true
    public var cardViewModels: [TriplogOverviewCardViewModelProtocol]
    public var analyticKey: String { return AnalyticsKeys.tripArchiveShown }
    private lazy var repository: TriplogOverviewRepositoryType = container.resolveTriplogRepo()
    private lazy var vehicleRepository: VehicleProfileRepositoryType = container.resolveVehicleProfileRepo()
    private var _currentFilteringVehicle: VehicleProfileType?
    public var currentFilteringVehicle: VehicleProfileType? {
        get {
            if _currentFilteringVehicle != nil {
                return _currentFilteringVehicle
            }
            let storedVehicles = vehicleRepository.activeVehicles
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

    init(with kilometers: Double, cards: [TriplogOverviewCardViewModelProtocol]) {
        let distance = NumberFormatter().distanceTraveledFormatted(value: kilometers)
        kilometersDrivenText = "\(distance) km"
        cardViewModels = cards
    }

    public func reloadData(clearCache: Bool? = false, completion: @escaping ((Bool) -> Void)) {
          delegate?.viewModelUpdated(self)
            completion(true)
    }

    public func monthDetailViewModel(for monthViewModel: TriplogOverviewCardViewModelProtocol) -> TriplogCardViewModelProtocol? {
        guard let monthData = monthViewModel.model,
              let detailModel = repository.cardOverviewModel(for: monthData) else { return nil }
        let detailViewModel = container.resolve(TriplogCardViewModelProtocol.self, argument: detailModel)
        return detailViewModel
    }

    public func archivedPeriodViewModel(for cardViewModel: TriplogOverviewCardViewModelProtocol) -> TriplogArchivePeriodOverViewModel? {
        guard let id = cardViewModel.model?.cardId,
            let discount = cardViewModel.model?.discountPercentage,
            let distance = cardViewModel.model?.kilometers,
            let start = cardViewModel.model?.startPeriod,
            let end = cardViewModel.model?.endPeriod else { return nil }
            let viewModel = container.resolve(TriplogArchivePeriodOverViewModel.self, arguments: id, discount, distance, start, end)
            viewModel?.currentFilteringVehicle = self.currentFilteringVehicle
        return viewModel
    }
}

// MARK: - TriplogArchivePeriodOverViewModel

//MARK: - Period Overview

public class TriplogArchivePeriodOverViewModel: TriplogOverviewViewModel {
    override public var drivingScoreText: String {
        get { "\(discountPercentage ?? 0) %" }
        set {}
    }

    override public var kilometersDrivenText: String {
        get { "\(NumberFormatter().distanceTraveledFormatted(value: distance ?? 0)) km" }
        set {}
    }

    override public var drivingScoreDescription: String {
        get { "triplog.tripArchive.discountTitle".localized }
        set {}
    }

    private var archivedId: String?
    private var discountPercentage: Int?
    private var distance: Double?
    private var start: Date?
    private var end: Date?

    override var data: TriplogOverviewDataType? {
        guard let id = archivedId else {
            return nil
        }
        return repository.archivedData(with: id)
    }

    required init(withArchivedId archivedId: String, discountPercentage: Int, distance: Double, start: Date, end: Date) {
        self.archivedId = archivedId
        self.discountPercentage = discountPercentage
        self.distance = distance
        self.start = start
        self.end = end
    }

    override public func reloadData(clearCache: Bool? = false, completion: @escaping ((Bool) -> Void)) {
        repository.fetch(overviewWith: archivedId, vehicleID: currentFilteringVehicle?.publicId) {[weak self] result in
            guard let `self` = self else {
                return
            }

            switch result {
            case .success(_):
                completion(true)
                self.delegate?.viewModelUpdated(self)
            case let .failure(error):
                self.delegate?.viewModelDidFail(with: error)
                completion(false)
            }
        }
    }

    public func titleForPeriod() -> String {
        guard let start = start, let end = end else { return "triplog.tripArchive.title".localized }
        return start.periodForEndFormatter(end: end)
    }

    override public func monthDetailViewModel(for monthViewModel: TriplogOverviewCardViewModelProtocol) -> TriplogCardViewModelProtocol? {
        var viewModel = super.monthDetailViewModel(for: monthViewModel)
        viewModel?.isPeriodOverView = true
        return viewModel
    }
}
