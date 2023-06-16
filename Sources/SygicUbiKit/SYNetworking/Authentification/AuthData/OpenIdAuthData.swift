import Foundation

struct OpenIdTokenData: Codable, AuthTokenDataType {
    var token_type: String
    var access_token: String
    var refresh_token: String
    var expires_in: Int
    var accessTokenExpirationDate: Date?
    var userId: String?
    var secureUserId: String?

    var authToken: String { "\(token_type) \(access_token)" }
    var authTokenNoType: String { access_token }

    var isFresh: Bool {
        guard let expirationDate = accessTokenExpirationDate else { return false }
        return expirationDate.timeIntervalSinceNow > expirationTolerance
    }

    var isValid: Bool {
        guard userId != nil && accessTokenExpirationDate != nil else { return false }
        return true
    }

    private let expirationTolerance: TimeInterval = 60

    enum CodingKeys: String, CodingKey {
        case token_type
        case access_token
        case refresh_token
        case expires_in

        case accessTokenExpirationDate
        case userId
        case secureUserId
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        token_type = try values.decode(String.self, forKey: .token_type)
        access_token = try values.decode(String.self, forKey: .access_token)
        refresh_token = try values.decode(String.self, forKey: .refresh_token)
        expires_in = try values.decode(Int.self, forKey: .expires_in)
        if let savedDate = try? values.decode(Date.self, forKey: .accessTokenExpirationDate) {
            accessTokenExpirationDate = savedDate
        } else {
            accessTokenExpirationDate = Date().addingTimeInterval(TimeInterval(expires_in))
        }
        userId = try? values.decode(String.self, forKey: .userId)
        secureUserId = try? values.decode(String.self, forKey: .secureUserId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token_type, forKey: .token_type)
        try container.encode(access_token, forKey: .access_token)
        try container.encode(refresh_token, forKey: .refresh_token)
        try container.encode(expires_in, forKey: .expires_in)
        try container.encode(accessTokenExpirationDate, forKey: .accessTokenExpirationDate)
        try container.encode(userId, forKey: .userId)
        try container.encode(secureUserId, forKey: .secureUserId)
    }
}
