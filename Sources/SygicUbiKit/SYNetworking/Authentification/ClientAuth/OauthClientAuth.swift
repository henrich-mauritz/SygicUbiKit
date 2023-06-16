//
//  OauthClientAuth.swift
//  SYNetworking
//
//  Created by Juraj Antas on 04/12/2022.
//

import Foundation
import AppAuth
import KeychainAccess

final class OauthClientAuth {
    
    enum Keys: String {
        case userId = "myUserId"
        case secureUserId = "mySecureUserId"
    }
    
    var configurationUrl: String
    var clientId: String
    var redirectUrl: String
    
    init(oauthConfigurationurl url: String, clientId: String, redirectUrl: String) {
        self.configurationUrl = url
        self.clientId = clientId
        self.redirectUrl = redirectUrl
        
        authState = loadState()
    }
    
    //preco kua toto tu musim mat je mimo moje chapanie. Vobec to nesuvisi s Oauth!
    var userId: String? {
        get {
            let value = UserDefaults.standard.string(forKey: Keys.userId.rawValue)
            return value
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.userId.rawValue)
        }
    }
    var secureUserId: String? {
        get {
            let value = UserDefaults.standard.string(forKey: Keys.secureUserId.rawValue)
            return value
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.secureUserId.rawValue)
        }
    }
    
    var authorized: Bool {
        get {
            return isLoggedIn()
        }
    }
    
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    private var authState: OIDAuthState?
    private let keychainServiceName = "OauthService"
    private let keychainOauthKey = "OauthService"
    private let oauthDataAreInKeychainKey = "oauthDataAreInKeychainKey"
    
    private func deleteState() {
        let keychain = Keychain(service: keychainServiceName)
        try? keychain.removeAll()
    }
    
    private func saveState(authState: OIDAuthState) {
        let keychain = Keychain(service: keychainServiceName)
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: true)
            try keychain.set(encodedData, key: keychainOauthKey)
            UserDefaults.standard.set(true, forKey: oauthDataAreInKeychainKey)
        }
        catch {
            print(error)
        }
    }
    
    private func loadState() -> OIDAuthState? {
        //only load state when oauthDataAreInKeychainKey exists and is set to true.
        //why?
        //because when user uninstalls the app, keychain data remain. So we need to make sure that user is logged off
        if UserDefaults.standard.bool(forKey: oauthDataAreInKeychainKey) == false {
            deleteState()
            return nil
        }
        
        let keychain = Keychain(service: keychainServiceName)
        do {
            if let data = try keychain.getData(keychainOauthKey) {
                if let authState = try NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data) {
                    return authState
                }
            }
            return nil
        }
        catch {
            print("\(error)")
            return nil
        }
    }
    
    
    
    func isLoggedIn() -> Bool {
        guard let authState = authState else {
            return false
        }
        
        //TODO: zverifikuj ze je to to co potrebujeme.
        if let dict = authState.lastTokenResponse?.additionalParameters {
            if let notBefore = dict["not_before"] as? Int, let refreshTokenExpirationTime = dict["refresh_token_expires_in"] as? Int {
                let futureTimestamp = Date(timeIntervalSince1970: Double(notBefore) + Double(refreshTokenExpirationTime)).timeIntervalSince1970
                let currentTimeStamp = Date().timeIntervalSince1970
                
                if currentTimeStamp > futureTimestamp {
                    //sme odhlaseny lebo refresh token expiroval
                    return false
                }
            }
        }
        
        
        return authState.isAuthorized
    }
    
    func loginAndMigrate(usingViewController viewController: UIViewController, completion: @escaping (Error?) -> Void) {
        login(usingViewController: viewController, policy: "b2c_1a_itriglav3_customemail_signup_signin_drajvmigration", completion: completion)
    }

    private func login(usingViewController viewController: UIViewController, policy: String ,completion: @escaping (Error?) -> Void) {
        
        var urlComponents = URLComponents(string: configurationUrl)!
        let queryItem = URLQueryItem(name: "p", value: policy)
        urlComponents.queryItems = [queryItem]
        
        guard let issuer = urlComponents.url else {
            return
        }
        
        OIDAuthorizationService.discoverConfiguration(forDiscoveryURL: issuer) { configuration, error in
            guard let config = configuration else {
                return
            }
            print("Got configuration: \(config)")

            self.doAuthWithAutoCodeExchange(configuration: config, clientID: self.clientId, clientSecret: nil, policy: policy, viewController: viewController, completion: completion)
        }
    }
    
    private func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?, policy: String, viewController: UIViewController, completion: @escaping (Error?) -> Void) {

        guard let redirectURI = URL(string: redirectUrl) else {
            return
        }

        let additionalParams :  [String:String] = ["p" : policy, "prompt" : "login"];
        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, clientID, "offline_access"],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: additionalParams)

        
        self.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: viewController) { authState, error in
            if let authState = authState {
                self.authState = authState
                self.saveState(authState: authState)
                
                print("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
                
                self.getUserId(completion: completion)
            } else {
                print("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                completion(error)
            }
        }
    }
    
    
    func getUserId(completion: @escaping (Error?) -> Void) {
        SecureUserId.fetchUserId { result in
            switch result {
            case let .success(data):
                self.userId = data.userId
                self.secureUserId = data.secureUserId
                completion(nil)
            case let .failure(error):
                completion(error)
            }
        }
    }
    
    func logout() {
        //sranda je ze v logout je potrebne mat request na server cize toto by mala byt async metoda.
        //ale pichnut async metodu a mat aj stary aj novy dizajn nie je prave jednoduche.
        //TODO: zavolaj logout aj na server, kasli na to ci to prejde alebo nie.
        //kde v AppAuth take cosi maju?
        
        //mark that we are logged off
        UserDefaults.standard.set(false, forKey: oauthDataAreInKeychainKey)
        self.deleteState()
        self.userId = nil
        self.secureUserId = nil
    }
    
    
    public func accessToken(force: Bool = false,
                            forwardTokens: @escaping (_ accessToken: String?, _ error: Error?) -> Void)
    {
        guard let authState = authState else {
            forwardTokens(nil, Auth.AuthError())
            return
        }
        //vraj toto vyriesi vsetky moje problemy s refresom tokenu...
        authState.performAction { accessToken, idToken, error in
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                forwardTokens(nil, error)
                return
            }
            guard let accessToken = accessToken else {
                forwardTokens(nil, Auth.AuthError())
                return
            }
            
            let acc = "Bearer \(accessToken)"
            
            forwardTokens(acc, nil)
        }
        
    }
}
