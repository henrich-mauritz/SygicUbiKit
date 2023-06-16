import CoreLocation
import Foundation
import MapKit

// MARK: - SosAssistanceModelProtocol

public protocol SosAssistanceModelProtocol {
    var emergencyContacts: [ContactData] { get }
}

// MARK: - ContactData

public protocol ContactData {
    var title: String { get }
    var subtitle: String? { get }
    var icon: UIImage? { get }
    var phoneNumber: String { get }
    var highlighted: Bool { get }
}

// MARK: - SosAssistanceViewModelDelegate

public protocol SosAssistanceViewModelDelegate: AnyObject {
    func viewModelUpdated(_ sender: Any)
}

// MARK: - SosAssistanceViewModelProtocol

public protocol SosAssistanceViewModelProtocol {
    var delegate: SosAssistanceViewModelDelegate? { get set }
    var currentLocationString: String? { get }
    var locationAvailable: Bool { get }
    var location: CLLocation? { get }
    var emergencyContacts: [ContactData] { get }
    func updateLocation(_ location: CLLocation)
}

// MARK: - SosAssistanceViewDelegate

public protocol SosAssistanceViewDelegate: AnyObject {
    func shouldShowMap(_ region: MKCoordinateRegion?)
    func shareLocation(_ location: CLLocation)
}

// MARK: - SosAssistanceViewProtocol

public protocol SosAssistanceViewProtocol where Self: UIView {
    var delegate: SosAssistanceViewDelegate? { get set }
    var viewModel: SosAssistanceViewModelProtocol? { get set }
}
