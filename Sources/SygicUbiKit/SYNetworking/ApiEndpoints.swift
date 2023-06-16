import Foundation

// MARK: - ApiEndpoints

/// API Endpoint protocol for SYNetworking API calls. Target URL is build from parameters provided.
public protocol ApiEndpoints {
    /// Endpoint name
    var endpoint: String { get }
    /// The HTTP request method. Default method is 'GET'.
    var requestMethod: String { get }
    /// Additional query items coded to requested endpoint URL
    func queryItems() -> [URLQueryItem]?
    /// Private API flag.
    /// Default: true. Auth token will be included in request header if token is available (user passed authentification).
    var requieresAuth: Bool { get }
    /// API version
    var version: Int { get }
    /// API defined custom headers for API requests
    var additionalRequestHeaders: [String: String]? { get }
    /// Endpoint URL, built from ApiEndpoint parameters.
    /// Default formatted: 'NetworkManagerConfigurable.api + "v\(version)/" + endpoint + queryItems...'
    var url: URL? { get }

    var authToken: String? { get }
}

public extension ApiEndpoints {
    var version: Int { 2 }

    var requieresAuth: Bool { true }

    var requestMethod: String { "GET" }

    var additionalRequestHeaders: [String: String]? { nil }

    var authToken: String? { return nil }

    var url: URL? {
        let urlString = NetworkManager.shared.configuration.api + "v\(version)/" + endpoint
        guard var components = URLComponents(string: urlString) else { return nil }
        if let queryItems = queryItems() {
            let encodedItems: [URLQueryItem] = queryItems.map { item -> URLQueryItem in
                let key = item.name
                guard let value = item.value else {
                    return item
                }
                var allowedCharacterSet = NSCharacterSet.urlQueryAllowed
                allowedCharacterSet.remove(charactersIn: ":+")
                let encodedItem = URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet))
                return encodedItem
            }
            components.percentEncodedQueryItems = encodedItems
        }
        return components.url
    }

    func queryItems() -> [URLQueryItem]? { return nil }

    func queryItems(from: Codable) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = [URLQueryItem]()
        let mirrored_object = Mirror(reflecting: from)
        for (_, attr) in mirrored_object.children.enumerated() {
            if let property_name = attr.label as String? {
                queryItems.append(URLQueryItem(name: property_name, value: "\(attr.value)"))
            }
        }
        return queryItems
    }
}
