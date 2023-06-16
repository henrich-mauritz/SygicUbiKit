import Foundation

// MARK: - SecureUserId

public struct SecureUserId: Codable {
    public static let secureUserIdRefreshDateKey = "secureUserIdRefreshDate"
    public static let secureUserIdExpirationDateKey = "secureUserIdExpirationDate"

    struct Container: Codable {
        var userId: String
        var secureUserId: String
        var secureUserIdRefreshDate: Date
        var secureUserIdExpirationDate: Date
    }

    var data: Container

    public var userId: String { data.userId }
    public var secureUserId: String { data.secureUserId }
    public var secureUserIdRefreshDate: Date { data.secureUserIdRefreshDate }
    public var secureUserIdExpirationDate: Date { data.secureUserIdExpirationDate }
}

public extension SecureUserId {
    static func fetchUserId(completion: @escaping (Result<SecureUserId, Error>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterSYNetworking.endpointGetUserId, completion: { (result: Result<SecureUserId, Error>) in
            if case let .success(userData) = result {
                UserDefaults.standard.set(userData.secureUserIdRefreshDate, forKey: SecureUserId.secureUserIdRefreshDateKey)
                UserDefaults.standard.set(userData.secureUserIdExpirationDate, forKey: SecureUserId.secureUserIdExpirationDateKey)
                //och...to snad nie.
                Auth.shared.clientAuth.updateSecureUserId(secureUserIdData: userData)
            }
            completion(result)
        })
    }
}
