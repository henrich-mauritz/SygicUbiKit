import Foundation
import UIKit

// MARK: - B2cClientAuth

open class B2cClientAuth: ClientAuthType {
    open var isAuthorized: Bool {
        authorizedData != nil
    }

    open var userId: String? { authorizedData?.userId }

    open var secureUserId: String? { authorizedData?.secureUserId }

    open var accessToken: String? {
        guard let data = authorizedData, data.isFresh else { return nil }
        return data.authToken
    }

    open var refresToken: String? {
        guard let data = authorizedData else { return nil }
        return data.refresh_token
    }

    open var idToken: String? {
        guard let data = authorizedData else { return nil }
        return data.id_token
    }

    /// B2C policies
    open var policies: B2cPolicyDefinable = B2cPolicies()

    private lazy var authorizedData: B2cAuthTokenData? = {
        B2cAuthTokenData.storedData()
    }()

    public init() {}

    open func logout() {
        authorizedData = nil
        B2cAuthTokenData.cleanKeychain()
    }

    /// Creates URLRequest with mandatory attributes for provided authPolicy.
    /// - Parameters:
    ///   - authPolicy: Requested auth policy
    ///   - signInType: Optional. Provides domain hint for Policy.signIn
    /// - Returns:URLRequest for authentification flow with provided Policy
    open func authorizationRequest(for authPolicy: Policy, signInType: SignInType?) -> URLRequest {
        var components = URLComponents(string: authorizeUrlString)!
        var queryItems: [URLQueryItem] = components.queryItems ?? [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "p", value: authPolicy.rawValue))
        queryItems.append(URLQueryItem(name: "client_id", value: clientId))
        queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectUrlString))
        queryItems.append(URLQueryItem(name: "scope", value: "openid offline_access"))
        queryItems.append(URLQueryItem(name: "response_type", value: "code"))
        queryItems.append(URLQueryItem(name: "prompt", value: "login"))
        queryItems.append(URLQueryItem(name: "osPlatform", value: "ios"))
        queryItems.append(URLQueryItem(name: "osVersion", value: UIDevice.current.systemVersion))
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            queryItems.append(URLQueryItem(name: "appVersion", value: appVersion))
        }
        if authPolicy.requiresAuthToken {
            queryItems.append(URLQueryItem(name: "cuActn", value: idToken))
        }
        if let socialJWT = authPolicy.socialJWT {
            queryItems.append(URLQueryItem(name: "externalIdentityToken", value: socialJWT))
        }
        queryItems.append(URLQueryItem(name: "uiThemeId", value: "dark"))
        queryItems.append(URLQueryItem(name: "ui_locales", value: NetworkManager.shared.languageLocaleHeaderValue()))
        if let signInType = signInType, let domain = signInType.domainHint {
            queryItems.append(URLQueryItem(name: "domain_hint", value: domain))
            switch signInType {
            case let .email(email):
                queryItems.append(URLQueryItem(name: "login_hint", value: email))
            case let .facebook(email):
                if let oldEmail = email {
                    queryItems.append(URLQueryItem(name: "login_hint", value: oldEmail))
                }
            }
        }
        components.queryItems = queryItems
        let request = URLRequest(url: components.url!)
        return request
    }

    /// URLRequest for obtaining access token by authorization code or refresh token.
    /// - Parameters:
    ///   - authorizationCode: Authorization code.  Normaly obtained by user login flow.
    ///   - refreshToken: Standard OAuth refresh token
    ///   - authPolicy: Authorization policy
    /// - Returns: URLRequest
    open func tokenRequest(with grandType: B2cTokenGrandType, for authPolicy: Policy) -> URLRequest {
        var components = URLComponents(string: tokenUrlString)!
        var queryItems: [URLQueryItem] = components.queryItems ?? [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "p", value: authPolicy.rawValue))
        queryItems.append(URLQueryItem(name: "client_id", value: clientId))
        queryItems.append(URLQueryItem(name: "scope", value: "openid offline_access"))
        queryItems.append(URLQueryItem(name: "grant_type", value: grandType.grandTypeValue))
        switch grandType {
        case let .authorization(code: authCode):
            queryItems.append(URLQueryItem(name: "code", value: authCode))
        case let .refreshToken(refreshToken: refreshToken):
            queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
        }
        components.queryItems = queryItems
        return URLRequest(url: components.url!)
    }

    /// Requests bearer token with provided authorization code and authorization policy
    /// - Parameters:
    ///   - authorizationCode: Authorization code.  Normaly obtained by user login flow.
    ///   - authPolicy: Authorization policy
    ///   - completion: completion block with request results
    /// - Returns: true if tokens were received successful
    open func requestBearerToken(with authorizationCode: String, for authPolicy: Policy, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        let request = tokenRequest(with: .authorization(code: authorizationCode), for: authPolicy)
        sendTokenRequest(request, policy: authPolicy) {[weak self] error in
            guard let self = self else { return }

            if error != nil {
                completion(false, error)
                return
            }
            guard var authorizedData = self.authorizedData else {
                completion(false, NetworkError.unknown)
                return
            }

            if authorizedData.userId == nil {
                    SecureUserId.fetchUserId { result in
                        switch result {
                        case let .success(data):
                            authorizedData.userId = data.userId
                            authorizedData.secureUserId = data.secureUserId
                            authorizedData.storeToKeychain()
                            completion(true, nil)
                        case let .failure(error):
                            completion(false, error)
                        }
                    }
                } else {
                    authorizedData.storeToKeychain()
                    completion(true, nil)
            }
        }
    }

    open func refreshAccessToken(completion: @escaping (Result<String, Error>) -> ()) {
        guard let refreshToken = self.refresToken, let authPolicy = authorizedData?.policy else {
            completion(.failure(Auth.AuthError()))
            return
        }
        let request = tokenRequest(with: .refreshToken(refreshToken: refreshToken), for: authPolicy)
        sendTokenRequest(request, policy: authPolicy) { [weak self] error in
            if error == nil, let newData = self?.authorizedData {
                completion(.success(newData.authToken))
            } else {
                if let syError = error as? NetworkError, let code = syError.httpErrorCode, code == 400 {
                    if code == 400 {
                        DispatchQueue.main.async {
                            Auth.shared.logout()
                            
                            let fileLineFunction = "\(#fileID), #:\(#line) \(#function)"
                            let dict = NetworkManager.shared.generateDictForLogout(errorCode: code, errorText: error?.localizedDescription ?? "N/A", fileLineFunction: fileLineFunction)
                            
                            NotificationCenter.default.post(name: NetworkManager.shared.unauthorizedNotification, object: error, userInfo: dict)
                        }
                        return
                    }
                }
                completion(.failure(error ?? Auth.AuthError()))
            }
        }
    }

    open func updateSecureUserId(secureUserIdData: SecureUserId) {
        authorizedData?.secureUserId = secureUserIdData.secureUserId
        authorizedData?.userId = secureUserIdData.userId
        authorizedData?.storeToKeychain()
    }

    open func sendTokenRequest(_ request: URLRequest, policy: Policy, completion: @escaping (_ error: Error?) -> ()) {
        NetworkManager.shared.sendRequest(urlRequest: request) { [weak self] result in
            switch result {
            case let .success(data):
                do {
                    var decodedData: B2cAuthTokenData = try NetworkManager.shared.decodeData(data: data)
                    decodedData.policy = policy
                    decodedData.userId = self?.authorizedData?.userId
                    decodedData.secureUserId = self?.authorizedData?.secureUserId
                    self?.authorizedData = decodedData
                    completion(nil)
                } catch let decodeError {
                    print(decodeError)
                    DispatchQueue.main.async {
                        completion(NetworkError.unknown)
                    }
                }
            case let .failure(error):
                print("TOKEN ERROR: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
}

public extension B2cClientAuth {
    enum B2cTokenGrandType {
        case authorization(code: String)
        case refreshToken(refreshToken: String)

        var grandTypeValue: String {
            switch self {
            case .authorization:
                return "authorization_code"
            case .refreshToken:
                return "refresh_token"
            }
        }
    }
}
