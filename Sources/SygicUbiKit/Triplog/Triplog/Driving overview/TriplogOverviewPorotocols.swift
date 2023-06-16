import Foundation
import UIKit

// MARK: - TriplogOverviewDataType

public protocol TriplogOverviewDataType {
    var score: Double { get }
    var kilometers: Double { get }
    var discount: Int { get }
    var cards: [TriplogOverviewCardDataType] { get }
    var overallTripCount: Int { get }
    var evaluatedPeriodTripCount: Int { get }
}

// MARK: - TileType

public enum TileType: String {
    case tripsForMonth
    case tripsForDateRange
    case archive
    case archivedPeriod
}

// MARK: - TriplogOverviewCardDataType

public protocol TriplogOverviewCardDataType {
    var cardType: TileType { get }
    var monthNumber: Int? { get }
    var yearNumber: Int? { get }
    var score: Double { get }
    var discountPercentage: Int? { get }
    var kilometers: Double { get }
    var cardId: String? { get }
    var startPeriod: Date? { get }
    var endPeriod: Date? { get }
    var childrenCards: [TriplogOverviewCardDataType]? { get }
    var detailId: String? { get }
}

// MARK: - TriplogViewModelDelegate

public protocol TriplogViewModelDelegate: AnyObject {
    func viewModelUpdated(_ sender: Any)
    func viewModelDidFail(with error: Error)
}

// MARK: - TriplogOverviewViewModelProtocol

public protocol TriplogOverviewViewModelProtocol {
    var delegate: TriplogViewModelDelegate? { get set }
    var drivingScoreText: String { get }
    var drivingScoreDescription: String { get }
    var kilometersDrivenText: String { get }
    var kilometersDrivenDescription: String { get }
    var hasData: Bool { get }
    var analyticKey: String { get }
    var cardViewModels: [TriplogOverviewCardViewModelProtocol] { get }
    var visualsConfig: TriplogOverviewViewVisualsConfigurable { get set }
    var hasMoreThanOneVehicle: Bool { get }
    var currentFilteringVehicle: VehicleProfileType? { get set }
    func reloadData(clearCache: Bool?, completion: @escaping ((_ finished: Bool) -> Void))
    func monthDetailViewModel(for monthViewModel: TriplogOverviewCardViewModelProtocol) -> TriplogCardViewModelProtocol?
}

public extension TriplogOverviewViewModelProtocol {
    var currentFilteringVehicle: VehicleProfileType? {
        get {
            return nil
        }
        set {
            //do nothing
        }
    }

    var hasMoreThanOneVehicle: Bool { false }
}

// MARK: - TriplogOverviewViewProtocol

public protocol TriplogOverviewViewProtocol where Self: UIView {
    var viewModel: TriplogOverviewViewModelProtocol? { get set }
    var monthsDelegate: TriplogMonthCardViewDelegate? { get set }
    func reloadTripsData(fromFail: Bool)
}

// MARK: - TriplogOverviewMonthCardProtocol

public protocol TriplogOverviewMonthCardProtocol where Self: UIView {
    var delegate: TriplogMonthCardViewDelegate? { get set }
    var viewModel: TriplogOverviewCardViewModelProtocol? { get set }
}

// MARK: - TriplogMonthCardViewDelegate

public protocol TriplogMonthCardViewDelegate: AnyObject {
    func triplogMonthCardDidSelect(_ item: TriplogOverviewCardViewModelProtocol)
    func presentMonthlyStatsTapped()
}

// MARK: - TriplogEmtpyStateViewDelegate

public protocol TriplogEmtpyStateViewDelegate {
    var image: UIImage? { get set }
    var title: String { get set }
    var subtitle: String { get set }
}

// MARK: - TriplogOverviewCardViewModelProtocol

public protocol TriplogOverviewCardViewModelProtocol {
    var model: TriplogOverviewCardDataType? { get set }
    var image: UIImage? { get }
    var score: String { get }
    var kilometers: String { get }
    var title: String { get }
    var isLongerPeriodCard: Bool { get }
    var cardType: TileType? { get }
    func canBeClicked() -> Bool
}

// MARK: - TriplogOverviewViewVisualsConfigurable

public protocol TriplogOverviewViewVisualsConfigurable {
    var displayOverviewScore: Bool { get }
    var displayDistanceValue: Bool { get }
}

public extension TriplogOverviewViewVisualsConfigurable {
    var displayOverviewScore: Bool { true }
    var displayDistanceValue: Bool { true }
}
