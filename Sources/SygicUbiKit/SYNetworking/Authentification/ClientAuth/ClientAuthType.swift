import Foundation

// MARK: - ClientAuthType

public protocol ClientAuthType {
    /// Returns true if user passed authorization flow and have stored credentials.
    var isAuthorized: Bool { get }
    /// Current logged user identifier
    var userId: String? { get }
    /// Current user identifier with limited validity. Used for some services authorization (ADAS lib).
    var secureUserId: String? { get }
    /// API access token. It should alwars return valid token. Otherway returns nil.
    var accessToken: String? { get }
    /// API refrsh token
    var refresToken: String? { get }
    /// API id token
    var idToken: String? { get }
    /// Sends request to refresh access token with valid refresh token
    /// - Parameter completion: Completion block with fresh accessToken or error
    func refreshAccessToken(completion: @escaping (Result<String, Error>) -> ())
    /// Method to update secureUserId
    /// - Parameter id: new secureUserId
    func updateSecureUserId(secureUserIdData: SecureUserId)
    /// Cleans all stored user credentials and invalidates tokens.
    func logout()
}

//fakt cool...ale plisty by sa nemali takto pouzivat..teraz potrebujem mat aj stary aj novy auth aktivny a mam problem
//glorifikovana globalna premenna. A ked to niekto posere tak sa pouzije prazdny string a chyba konfiguracie sa zisti az za behu. + pridavat nove kluce pre novy auth a potom mat aj novy aj stary v pliste...no neviem..
//TODO: info o nastaveni by sa malo preniest ako vstup do libky, nie ocakavat nejaky setup v plistoch.
public extension ClientAuthType {
    var authorizeUrlString: String { configString(for: authorizeUrlKey) }
    var tokenUrlString: String { configString(for: tokenUrlKey) }
    var redirectUrlString: String { configString(for: redirectUrlKey) }
    var clientId: String { configString(for: authClientIdKey) }
    var authorizeUrlKey: String { "AUTH_URL_AUTHORIZE" }
    var tokenUrlKey: String { "AUTH_URL_TOKEN" }
    var redirectUrlKey: String { "AUTH_URL_REDIRECT" }
    var authClientIdKey: String { "AUTH_CLIENT_ID" }
    var idToken: String? { return nil }
    func configString(for key: String) -> String {
        Bundle.main.infoDictionary?[key] as? String ?? ""
    }
}
