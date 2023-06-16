import Foundation

// MARK: - OpenIdClientAccessTokenError

enum OpenIdClientAccessTokenError: String {
    case unknownError = "unknown_error"
    case invalidRequest = "invalid_request"
    case invalidClient = "invalid_client"
    case unsupportedGranTtype = "unsupported_grant_type"
    case invalidGrantType = "invalid_grant"
    case invalidScore = "invalid_scope"
    case missingDeviceId = "missing_device_id"
}

// MARK: - OpenIdClientAuth

open class OpenIdClientAuth: ClientAuthType {
    open var isAuthorized: Bool { authorizedData != nil }

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

    private var authorizedData: OpenIdTokenData?

    public init() {
        authorizedData = OpenIdTokenData.storedData()
    }

    open func logout() {
        logoutFromServer()
        authorizedData = nil
        OpenIdTokenData.cleanKeychain()
    }

    /// Authenticate user with provided credentials. Requests API access token and stores it to keychain.
    /// - Parameters:
    ///   - username: User login identifier
    ///   - password: Authorization token or user password
    ///   - completion: Block called after authorization finished. Contains error if authorization failed.
    open func authenticate(with username: String, password: String, completion: @escaping (_ error: Error?) -> ()) {
        if isAuthorized {
            logout()
        }
        let requestData = OAuthTokenRequestData(with: .password(username: username, password: password), clientId: clientId)
        sendTokenRequest(with: requestData) { error in
            completion(error)
        }
    }

    open func refreshAccessToken(completion: @escaping (Result<String, Error>) -> ()) {
        guard let refreshToken = self.refresToken else {
            completion(.failure(Auth.AuthError()))
            return
        }
        let requestData = OAuthTokenRequestData(with: .refreshToken(refreshToken: refreshToken), clientId: clientId)
        sendTokenRequest(with: requestData) { [weak self] error in
            if error == nil, let newData = self?.authorizedData {
                completion(.success(newData.authToken))
            } else {
                if let syError = error as? NetworkError, let code = syError.httpErrorCode, code == 400 {
                    if let userInfo = syError.httpUserInfo, let errorDescription = userInfo["error"] as? String, errorDescription == OpenIdClientAccessTokenError.invalidGrantType.rawValue {
                        DispatchQueue.main.async {
                            Auth.shared.logout()
                            
                            let fileLineFunction = "\(#fileID), #:\(#line) \(#function)"
                            let dict = NetworkManager.shared.generateDictForLogout(errorCode: code, errorText: error?.localizedDescription ?? "N/A", fileLineFunction: fileLineFunction)
                            
                            NotificationCenter.default.post(name: NetworkManager.shared.unauthorizedNotification, object: syError, userInfo: dict)
                        }
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

    private func sendTokenRequest(with requestData: OAuthTokenRequestData, completion: @escaping (_ error: Error?) -> ()) {
        NetworkManager.shared.requestAPI(OAuthApiRouter.oauthToken, postData: requestData) { [weak self] (result: Result<OpenIdTokenData?, Error>) in
            switch result {
            case let .success(resultData):
                guard var authData = resultData else {
                    fatalError("Auth token data expected!")
                }
                authData.userId = self?.authorizedData?.userId
                authData.secureUserId = self?.authorizedData?.secureUserId
                self?.authorizedData = authData
                DispatchQueue.main.async {
                    guard authData.userId == nil else {
                        authData.storeToKeychain()
                        completion(nil)
                        return
                    }
                    SecureUserId.fetchUserId { result in
                        switch result {
                        case let .success(data):
                            authData.userId = data.userId
                            authData.secureUserId = data.secureUserId
                            authData.storeToKeychain()
                            self?.authorizedData = authData
                            completion(nil)
                        case let .failure(error):
                            completion(error)
                        }
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

    private func logoutFromServer() {
        guard let refreshToken = self.refresToken else { return }
        let logoutData = OAuthLogoutRequestData(client_id: clientId, token: refreshToken)
        NetworkManager.shared.requestAPI(OAuthApiRouter.oauthLogout, postData: logoutData) { (result: Result<OAuthLogoutResponseData?, Error>) in
            switch result {
            case .success:
                print("API logout successful")
            case let .failure(error):
                print("API logout error: \(error)")
            }
        }
    }
}

//MARK: - Private definitions

private extension OpenIdClientAuth {
    enum OAuthTokenGrandType {
        case password(username: String, password: String)
        case refreshToken(refreshToken: String)

        var grandTypeValue: String {
            switch self {
            case .password:
                return "password"
            case .refreshToken:
                return "refresh_token"
            }
        }
    }

    struct OAuthTokenRequestData: Codable {
        var client_id: String
        var grant_type: String
        var scope: String? { grant_type == "password" ? "openid offline_access" : nil }
        var username: String?
        var password: String?
        var refresh_token: String?

        init(with grandType: OAuthTokenGrandType, clientId: String) {
            client_id = clientId
            grant_type = grandType.grandTypeValue
            switch grandType {
            case let .password(username: username, password: password):
                self.username = username
                self.password = password
            case let .refreshToken(refreshToken: token):
                self.refresh_token = token
            }
        }
    }

    struct OAuthLogoutRequestData: Codable {
        var client_id: String
        var token: String
        var token_type_hint: String = "refresh_token"
    }

    struct OAuthLogoutResponseData: Codable {}
}
