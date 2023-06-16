import Foundation

//MARK: - B2cClientAuth

public extension B2cClientAuth {
    enum Policy {
        case signIn
        case signUp
        case passwordChange
        case passwordReset
        case profile
        case profileEdit
        case removeAccount
        case finalizeProfile
        case socialLogin(_ jwt: String)
        case custom(_ name: String, _ authTokenNeeded: Bool)

        public init?(with policyName: String, authTokenNeeded: Bool = true) {
            guard let clientAuth = NetworkManager.shared.configuration.clientAuth as? B2cClientAuth else { return nil }
            switch policyName.lowercased() {
            case clientAuth.policies.signIn:
                self = .signIn
            case clientAuth.policies.signUp:
                self = .signUp
            case clientAuth.policies.passwordChange:
                self = .passwordChange
            case clientAuth.policies.passwordReset:
                self = .passwordReset
            case clientAuth.policies.profile:
                self = .profile
            case clientAuth.policies.profileEdit:
                self = .profileEdit
            case clientAuth.policies.removeAccount:
                self = .removeAccount
            case clientAuth.policies.finalizeProfile:
                self = .finalizeProfile
            case clientAuth.policies.socialLogin:
                self = .socialLogin("") //no need to store the apple JWT
            default:
                self = .custom(policyName, authTokenNeeded)
            }
        }

        public var rawValue: String {
            guard let clientAuth = NetworkManager.shared.configuration.clientAuth as? B2cClientAuth else {
                print("Wrong clientAuth. Define B2cClientAuth to use B2C policies.")
                return ""
            }
            switch self {
            case .signIn:
                return clientAuth.policies.signIn
            case .signUp:
                return clientAuth.policies.signUp
            case .passwordChange:
                return clientAuth.policies.passwordChange
            case .passwordReset:
                return clientAuth.policies.passwordReset
            case .profile:
                return clientAuth.policies.profile
            case .profileEdit:
                return clientAuth.policies.profileEdit
            case .removeAccount:
                return clientAuth.policies.removeAccount
            case .finalizeProfile:
                return clientAuth.policies.finalizeProfile
            case let .custom(policyName, _):
                return policyName
            case .socialLogin(_):
                return clientAuth.policies.socialLogin
            }
        }

        public var requiresAuthToken: Bool {
            switch self {
            case .signIn, .signUp, .passwordReset:
                return false
            case let .custom(_, authNeeded):
                return authNeeded
            default:
                return true
            }
        }

        public var socialJWT: String? {
            switch self {
            case let .socialLogin(jwt):
                return jwt
            default:
                return nil
            }
        }
    }
}

// MARK: - B2cClientAuth.Policy + Equatable

extension B2cClientAuth.Policy: Equatable {}

// MARK: - B2cPolicyDefinable

public protocol B2cPolicyDefinable {
    var signIn: String { get }
    var signUp: String { get }
    var passwordChange: String { get }
    var passwordReset: String { get }
    var profile: String { get }
    var profileEdit: String { get }
    var removeAccount: String { get }
    var finalizeProfile: String { get }
    var socialLogin: String { get }
}

public extension B2cPolicyDefinable {
    var signIn: String { "b2c_1a_signin" }
    var signUp: String { "b2c_1a_signup" }
    var passwordChange: String { "b2c_1a_passwordchange" }
    var passwordReset: String { "b2c_1a_passwordreset" }
    var profile: String { "b2c_1a_profile" }
    var profileEdit: String { "b2c_1a_profile_edit" }
    var removeAccount: String { "b2c_1a_removeaccount" }
    var finalizeProfile: String { "b2c_1a_finalize_profile" }
    var socialLogin: String { "b2c_1a_native_social_auth" }
}

// MARK: - B2cPolicies

struct B2cPolicies: B2cPolicyDefinable {}

//MARK: - SignInType

public extension B2cClientAuth {
    enum SignInType {
        case email(_ email: String)
        case facebook(_ email: String?)

        var domainHint: String? {
            switch self {
            case .email:
                return "email"
            case .facebook:
                return "facebook.com"
            }
        }
    }
}
