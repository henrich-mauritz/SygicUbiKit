import CoreLocation
import Foundation
import SygicMaps

// MARK: - ApiRouterBadges

struct SosAssistanceApiRouter: ApiEndpoints {
    let userLocation: CLLocationCoordinate2D

    var endpoint: String = "reversegeocode"

    var url: URL? {
        let bundledUri = Bundle.main.infoDictionary?["REVERSE_GEOCODING_URL"] as? String
        guard let uri = bundledUri else {
            return nil
        }
        let finalURI = uri + "/v2/api/" + endpoint
        guard var components = URLComponents(string: finalURI) else { return nil }
        components.queryItems = queryItems()
        return components.url
    }

    var requieresAuth: Bool { true }

    var authToken: String? {
        let result = SygicAuthorization.shared.getAuthTokenSync()
        return result
        //toto je hovadina par excelance. token sa musi refreshovat. ako si mozeme byt isty ze SYOnlineSession ma cerstvy token?!
        /*
        if SYContext.isInitialized() {
            if let token = SYOnlineSession.shared().accessToken {
                return "bearer " + token
            }
            return nil
        }
        return nil
         */
    }

    func queryItems() -> [URLQueryItem]? {
        return [URLQueryItem(name: "location", value: String(format: "%f,%f", userLocation.latitude, userLocation.longitude))]
    }
}

// MARK: - ReverseGeoCodedModel

public struct ReverseGeoCodedModel: Codable {
    public struct ResultList: Codable {
        public struct Components: Codable {
            var type: String
            var value: String
        }

        public struct Location: Codable {
            var lat: Double
            var lon: Double
        }

        public var components: [Components]
        public var formatted_result: String
        public var location: Location
        public var type: String
        public var location_type: String
        public var country_iso: String
    }

    public var status: String
    public var results: [ResultList]
    public var copyright: String
}
