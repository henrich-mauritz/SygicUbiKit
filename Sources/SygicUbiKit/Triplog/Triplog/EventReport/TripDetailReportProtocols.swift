import Foundation
import MapKit
import UIKit

// MARK: - TripDetailReportViewProtocol

public protocol TripDetailReportViewProtocol where Self: UIView {
    var delegate: TripDetailReportViewDelegate? { get set }
    var viewModel: TripDetailReportViewModelProtocol? { get set }
}

// MARK: - TripDetailReportViewDelegate

public protocol TripDetailReportViewDelegate where Self: UIViewController {
    func reportCanceled()
    func reportSubmited(result: Result<Bool, Error>)
    func wrongInput()
}

// MARK: - TripDetailReportViewControllerDelegate

public protocol TripDetailReportViewControllerDelegate: AnyObject {
    func reportSubmited(result: Result<Bool, Error>)
}

// MARK: - TripDetailReportViewControllerProtocol

public protocol TripDetailReportViewControllerProtocol where Self: UIViewController {
    var viewModel: TripDetailReportViewModelProtocol? { get set }
    var delegate: TripDetailReportViewControllerDelegate? { get set }
}

// MARK: - TripDetailReportViewModelDelegate

public protocol TripDetailReportViewModelDelegate: AnyObject {
    func viewModelUpDated()
}

// MARK: - TripDetailReportViewModelProtocol

public protocol TripDetailReportViewModelProtocol {
    var model: TripDetailReportModelProtocol? { get set }
    var delegate: TripDetailReportViewModelDelegate? { get set }
    var tripCoordinates: [CLLocationCoordinate2D]? { get set }
    var eventDetail: TripDetailEvent? { get set }
    var tripId: String? { get set }
    var eventNumber: Int? { get set }
    var speedLimit: Double? { get set }
    var route: [EventRoute]? { get }
    var reportPoint: CLLocationCoordinate2D? { get set }
    var currentFilteringVehicle: VehicleProfileType? { get set }
    func getEventDetail()
    func reportSpeedLimit(_ reason: String, speedLimit: Int, completion: @escaping (Result<Bool, Error>) -> ())
    func getClosestReportPoint(point: CLLocationCoordinate2D) -> EventRoute?
}
