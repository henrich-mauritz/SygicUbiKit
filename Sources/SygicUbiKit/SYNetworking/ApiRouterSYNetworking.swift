import Foundation
import UIKit

// MARK: - ApiRouterBadges

enum ApiRouterSYNetworking: ApiEndpoints {
    case endpointGetUserId
    case endpointUpdateAvaiable

    public var endpoint: String {
        switch self {
        case .endpointGetUserId:
            return "security/user-id"
        case .endpointUpdateAvaiable:
            return "apps/update-status"
        }
    }

    var requieresAuth: Bool {
        switch self {
        case .endpointUpdateAvaiable:
            return false
        default:
            return true
        }
    }
}

// MARK: - OAuthApiRouter

enum OAuthApiRouter: ApiEndpoints {
    case oauthToken
    case oauthIntrospect
    case oauthLogout

    var version: Int { 1 }

    var requestMethod: String { "POST" }

    public var endpoint: String {
        switch self {
        case .oauthToken:
            return "oauth2/token"
        case .oauthIntrospect:
            return "oauth2/introspect"
        case .oauthLogout:
            return "oauth2/revocation"
        }
    }

    var requieresAuth: Bool { false }

    var additionalRequestHeaders: [String: String]? {
        let vendoreId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        return ["X-Device-Id": vendoreId.sha256()]
    }

    var url: URL? {
        let authApiUrl = Bundle.main.infoDictionary?["AUTH_URL"] as? String ?? ""
        let urlString = authApiUrl + "v\(version)/" + endpoint
        return URL(string: urlString)
    }
}
