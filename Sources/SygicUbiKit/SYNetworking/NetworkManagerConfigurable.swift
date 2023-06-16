import Foundation

// MARK: - NetworkManagerConfigurable

public protocol NetworkManagerConfigurable {
    /// Url path to API gateway (format: "https://mysuperapp.com/api/")
    var api: String { get }

    /// User-Agent: format project/{appPlatform}/{appVersion} - priklad: Sygic/iOS/1.2.3
    var userAgent: String { get }

    /// Predefined app languages requested for server API requests. Device default language will be selected if empty.
    var supportedLanguages: [String] { get }
    
    /// App defined headers for API requests
    var additionalRequestHeaders: [String: String]? { get }

    /// App authentification interface.
    /// - Predefined B2cClientAuth or OpenIdClientAuth can be used or app can define completely custom solution.
    var clientAuth: ClientAuthType? { get }
}

public extension NetworkManagerConfigurable {
    var additionalRequestHeaders: [String: String]? { nil }
}

// MARK: - DefaultConfiguration

class DefaultConfiguration: NetworkManagerConfigurable {
    public var api: String = ""
    public var userAgent: String = ""
    public var supportedLanguages: [String] = []
    public var preferedLanguage: String = ""
    public lazy var clientAuth: ClientAuthType? = { B2cClientAuth() }()
}
