import Foundation
import UIKit

// MARK: - TriplogCardModelProtocol

public protocol TriplogCardModelProtocol: TriplogOverviewCardDataType {
    var loading: Bool { get }
    var cardType: TileType { get }
    func loadTrips(completion: @escaping (Result<TriplogTripsDataType, Error>) -> ())
    func loadMoreTrips(completion: @escaping (Result<TriplogTripsDataType, Error>) -> ())
}

// MARK: - TriplogTripsDataType

public protocol TriplogTripsDataType {
    var trips: [TriplogTripDataType] { get }
}

// MARK: - TriplogTripDataType

public protocol TriplogTripDataType {
    var id: String { get }
    var startTime: Date { get }
    var endTime: Date { get }
    var overallScore: Double? { get }
    var locationStartName: String { get }
    var locationEndName: String { get }
    var distanceKm: Double { get }
    var imageUri: String? { get }
    var startLocation: NetworkLocation { get }
    var endLocation: NetworkLocation { get }
}

// MARK: - TriplogCardViewModelProtocol

public protocol TriplogCardViewModelProtocol {
    var model: TriplogOverviewCardDataType? { get set }
    var delegate: TriplogViewModelDelegate? { get set }
    var monthTitle: String { get }
    var drivingScoreText: String { get }
    var drivingScoreDescription: String { get }
    var kilometersDrivenText: String { get }
    var kilometersDrivenDescription: String { get }
    var isPeriodOverView: Bool { get set }
    var trips: [TriplogTripCardViewModelProtocol] { get }
    var listingType: TriplogMonthlyListingType { get set }
    var categorizedTrips: [TriplogDateSectionTripModel] { get }
    var loading: Bool { get }
    var currentFilteringVehicle: VehicleProfileType? { get set }
    var isCurrentMonth: Bool { get }
    func reloadTrips(purgeData: Bool, completion: @escaping ((_ finished: Bool) -> Void))
    //func reloadTrips(completion:@escaping((_ finished:Bool) -> Void))
    func loadMoreTrips()
    func tripDetailViewModel(for trip: TriplogTripCardViewModelProtocol) -> TripDetailViewModelProtocol?
}

// MARK: - TriplogTripCardViewModelProtocol

public protocol TriplogTripCardViewModelProtocol {
    var data: TriplogTripDataType? { get set }
    var dateText: String { get }
    var normalizedDate: Date? { get }
    var scoreText: String { get }
    var destinationText: String { get }
    var descriptionText: String { get }
    var imageUrl: String? { get }
}

// MARK: - TriplogMonthViewProtocol

public protocol TriplogMonthViewProtocol where Self: UIView {
    var delegate: TriplogMonthViewDelegate? { get set }
    var viewModel: TriplogCardViewModelProtocol? { get set }
    func update(with viewModel: TriplogCardViewModelProtocol)
    func toggleActivityIndicator(value: Bool)
}

// MARK: - TriplogMonthViewDelegate

public protocol TriplogMonthViewDelegate: AnyObject {
    func triplogMonthViewDidSelect(_ view: TriplogMonthViewProtocol, trip: TriplogTripCardViewModelProtocol)
    func triplogMonthViewReloadTrips(_ view: TriplogMonthViewProtocol)
    func triplogMonthViewLoadMoreTrips(_ view: TriplogMonthViewProtocol)
}

// MARK: - TriplogTripCollectiocCellProtocol

public protocol TriplogTripCollectiocCellProtocol where Self: UICollectionViewCell {
    func update(with viewModel: TriplogTripCardViewModelProtocol)
}
