import Foundation

public struct B2cAuthTokenData: Codable, AuthTokenDataType {
    var token_type: String
    var id_token: String
    var refresh_token: String
    var not_before: Int
    var id_token_expires_in: Int
    var refresh_token_expires_in: Int
    var policy: B2cClientAuth.Policy?
    var idTokenExpirationDate: Date?
    var refreshTokenExpirationDate: Date?
    var userId: String?
    var secureUserId: String?

    public var authToken: String { "\(token_type) \(id_token)" }

    var isFresh: Bool {
        guard let expirationDate = idTokenExpirationDate else { return false }
        return expirationDate.timeIntervalSinceNow > expirationTolerance
    }

    var isValid: Bool {
        guard userId != nil && policy != nil && idTokenExpirationDate != nil && refreshTokenExpirationDate != nil else { return false }
        return true
    }

    public var authTokenNoType: String { id_token }

    private let expirationTolerance: TimeInterval = 60

    enum CodingKeys: String, CodingKey {
        case token_type
        case id_token
        case refresh_token
        case not_before
        case id_token_expires_in
        case refresh_token_expires_in

        case policyString
        case idTokenExpirationDate
        case refreshTokenExpirationDate
        case userId
        case secureUserId
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        token_type = try values.decode(String.self, forKey: .token_type)
        id_token = try values.decode(String.self, forKey: .id_token)
        refresh_token = try values.decode(String.self, forKey: .refresh_token)
        not_before = try values.decode(Int.self, forKey: .not_before)
        id_token_expires_in = try values.decode(Int.self, forKey: .id_token_expires_in)
        refresh_token_expires_in = try values.decode(Int.self, forKey: .refresh_token_expires_in)

        if let policyString = try? values.decode(String.self, forKey: .policyString) {
            policy = B2cClientAuth.Policy(with: policyString)
        }
        if let savedDate = try? values.decode(Date.self, forKey: .idTokenExpirationDate) {
            idTokenExpirationDate = savedDate
        } else {
            idTokenExpirationDate = Date().addingTimeInterval(TimeInterval(id_token_expires_in))
        }
        if let savedDate = try? values.decode(Date.self, forKey: .refreshTokenExpirationDate) {
            refreshTokenExpirationDate = savedDate
        } else {
            refreshTokenExpirationDate = Date().addingTimeInterval(TimeInterval(refresh_token_expires_in))
        }
        userId = try? values.decode(String.self, forKey: .userId)
        secureUserId = try? values.decode(String.self, forKey: .secureUserId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token_type, forKey: .token_type)
        try container.encode(id_token, forKey: .id_token)
        try container.encode(refresh_token, forKey: .refresh_token)
        try container.encode(not_before, forKey: .not_before)
        try container.encode(id_token_expires_in, forKey: .id_token_expires_in)
        try container.encode(refresh_token_expires_in, forKey: .refresh_token_expires_in)
        if let policyString = policy?.rawValue {
            try container.encode(policyString, forKey: .policyString)
        }
        try container.encode(idTokenExpirationDate, forKey: .idTokenExpirationDate)
        try container.encode(refreshTokenExpirationDate, forKey: .refreshTokenExpirationDate)
        try container.encode(userId, forKey: .userId)
        try container.encode(secureUserId, forKey: .secureUserId)
    }
}
