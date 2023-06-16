import Foundation
import Swinject
import UIKit

// MARK: - TriplogDefaultOverviewVisuals

struct TriplogDefaultOverviewVisuals: TriplogOverviewViewVisualsConfigurable {}

// MARK: - TriplogOverviewViewModel

public class TriplogOverviewViewModel: TriplogOverviewViewModelProtocol, InjectableType {
    public weak var delegate: TriplogViewModelDelegate?
    public var drivingScoreText: String {
        let score = data?.score ?? 0
        if let tripCount = data?.evaluatedPeriodTripCount, tripCount == 0 {
                    return "-"
        }
        return Format.scoreFormatted(value: score)
    }

    public var drivingScoreDescription: String = "triplog.overview.scoreTitle".localized
    public var kilometersDrivenText: String {
        var kilometers: Double = 0
        if let data = data {
            kilometers = data.kilometers
        }
        return "\(NumberFormatter().distanceTraveledFormatted(value: kilometers)) km"
    }

    public var kilometersDrivenDescription: String = "triplog.overview.distanceTitle".localized
    public var analyticKey: String { return AnalyticsKeys.triplogShown }
    public var cardViewModels: [TriplogOverviewCardViewModelProtocol] {
        data?.cards.compactMap {
            guard var viewModel = container.resolve(TriplogOverviewCardViewModelProtocol.self) else { return nil }
            viewModel.model = $0
            return viewModel
        } ?? []
    }

    lazy var repository: TriplogOverviewRepositoryType = container.resolveTriplogRepo()
    public func archiveViewModel() -> TriplogOverviewViewModelProtocol? {
        let archive = data?.cards.first(where: { $0.cardType == .archive })
        let cards = (archive?.childrenCards)!
        let kilometers = archive?.kilometers ?? 0
        let newCards: [TriplogOverviewCardViewModelProtocol] = cards.compactMap {
        guard var viewModel = container.resolve(TriplogOverviewCardViewModelProtocol.self) else { return nil}
            viewModel.model = $0
            return viewModel
        }
        var viewModel = container.resolve(TriplogOverviewViewModelProtocol.self, name: TriplogResolversNames.archiveResolver, arguments: kilometers, newCards)
        viewModel?.currentFilteringVehicle = self.currentFilteringVehicle
        return viewModel
    }

    public var hasData: Bool {
        let data = repository.data
        return data != nil
    }

    var data: TriplogOverviewDataType? { return repository.data }
    private var notificationsObservers = [NSObjectProtocol]()
    public var visualsConfig: TriplogOverviewViewVisualsConfigurable = TriplogDefaultOverviewVisuals()
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

    public var hasMoreThanOneVehicle: Bool {
        vehicleRepository.activeVehicles.count > 1
    }

    init() {
        notificationsObservers.append(NotificationCenter.default.addObserver(forName: .newTripScoreNotification, object: nil, queue: .main) { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.viewModelUpdated(weakSelf)
        })

        observeNetworkChange()
        if let resolvedVisuals = container.resolve(TriplogOverviewViewVisualsConfigurable.self) {
            visualsConfig = resolvedVisuals
        }
    }

    deinit {
        notificationsObservers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }

    public func reloadData(clearCache: Bool? = false, completion: @escaping ((_ finished: Bool) -> Void)) {
        if let clearCache = clearCache, clearCache == true {
            repository.purgueData()
        }
        repository.fetch(overviewWith: nil, vehicleID: currentFilteringVehicle?.publicId) { [weak self] result in
            guard let self = `self` else { //must unrap here so the viewModelUpdated doesn't need to force unwrap
                return
            }
            switch result {
            case .success(_):
                self.delegate?.viewModelUpdated(self)
                completion(true)
            case let .failure(error):
                self.repository.purgueData() //we dont want to show aby data over error states
                self.delegate?.viewModelDidFail(with: error)
                completion(false)
            }
        }
    }

    public func monthDetailViewModel(for monthViewModel: TriplogOverviewCardViewModelProtocol) -> TriplogCardViewModelProtocol? {
        guard let monthData = monthViewModel.model,
              let detailModel = repository.cardOverviewModel(for: monthData) else {
                return nil
        }
        var detailViewModel = container.resolve(TriplogCardViewModelProtocol.self, argument: detailModel)
        detailViewModel?.currentFilteringVehicle = self.currentFilteringVehicle
        return detailViewModel
    }
}

extension TriplogOverviewViewModel {
    func observeNetworkChange() {
        notificationsObservers.append(NotificationCenter.default.addObserver(forName: .flagsChanged,
                                                                             object: nil,
                                                                             queue: nil) {[weak self] _ in
                                                DispatchQueue.main.async {
                                                    switch ReachabilityManager.shared.status {
                                                    case .wwan, .wifi:
                                                        self?.reloadData(completion: { _ in })
                                                    default:
                                                        print("no connection reached")
                                                    }
                                                }
        })
    }
}
