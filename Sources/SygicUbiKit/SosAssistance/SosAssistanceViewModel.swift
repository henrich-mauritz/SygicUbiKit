import CoreLocation
import Foundation

public class SosAssistanceViewModel: SosAssistanceViewModelProtocol {
    public weak var delegate: SosAssistanceViewModelDelegate?
    private var lastLocation: CLLocation?
    public var currentLocationString: String? {
        guard let location = location else { return nil }
        guard let reverseGeoCodingData = self.reverseGeoCodingData, let firstResult = reverseGeoCodingData.results.filter({ result -> Bool in
            result.components.contains { $0.type == "street" && $0.value != "(Unnamed Road)" }
        }).first else {
            return location.ddFormat
        }

        return String(format: "%@\n%@", firstResult.formatted_result, location.ddFormat)
    }

    public var locationAvailable: Bool { CLLocationManager().authorizationStatus == .authorizedAlways || CLLocationManager().authorizationStatus == .authorizedWhenInUse }
    public var emergencyContacts: [ContactData]
    public var reverseGeoCodingData: ReverseGeoCodedModel?
    private var thresholdDistance: Double {
        guard let lastLocation = self.lastLocation, let location = self.location else {
            return 0
        }
        let distance = location.distance(from: lastLocation)
        return distance
    }

    private var shouldReverseCode: Bool {
        return ((thresholdDistance == 0 && lastLocation == nil) || thresholdDistance > 50) && !reverseSearching
    }

    public private(set) var location: CLLocation? {
        didSet {
            reversGeoCodeSearch()
        }
    }

    private var reverseSearching: Bool = false

    //MARK: - lifecycle

    public init(with model: SosAssistanceModel) {
        emergencyContacts = model.emergencyContacts
    }

    public func updateLocation(_ location: CLLocation) {
        self.location = location
    }

    public func reversGeoCodeSearch() {
        guard let location = self.location, shouldReverseCode else {
            return
        }
        reverseSearching = true
        self.delegate?.viewModelUpdated(self) //to show at the very begining at least the position
        SygicMapsInitializer.initializeSDK { _ in
            NetworkManager.shared.requestAPI(SosAssistanceApiRouter(userLocation: location.coordinate)) {[weak self] (result: Result<ReverseGeoCodedModel, Error>) in
                guard let self = self else {
                    return
                }
                self.lastLocation = location
                switch result {
                case .failure(_):
                    self.delegate?.viewModelUpdated(self)
                    return
                case let .success(reverseGeoCodingData):
                    self.reverseGeoCodingData = reverseGeoCodingData
                    self.delegate?.viewModelUpdated(self)
                }
                self.reverseSearching = false
            }
        }
    }
}
