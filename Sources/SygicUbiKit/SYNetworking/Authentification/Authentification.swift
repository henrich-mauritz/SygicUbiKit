import Foundation
import WebKit

//TODO: Objekty z kniznice sa maju inicializovat s parametrami v inite. Nie cheatovat ze si potiahneme konfiguraciu z plistov.
//TODO: predpoklad ze v apke bude len jeden Auth je chybny. Prilis pouzivame singletony. To robi dizajn rigidny.
//jedina vec ktora je v apke len jedna je apka samotna. Odporucam skopirovat dizajn swiftUI, kedy globalny objekt je jeden, AppEnv alebo podobne meno a v nom su dalsie podsystemy ktore ale nie su singletony. tj. daju sa jednoducho vymenit.


public extension Notification.Name {
    static var userLoggedOut: Notification.Name { Notification.Name("AuthentificationUserLoggedOut") }
}

// MARK: - Auth


/// Provides interface for all authentification related stuff.
public class Auth: InjectableType {
    public static let shared = Auth()

    private var newOauth: OauthClientAuth?
    //TODO: leak of data outside Auth.
    public var clientAuth: ClientAuthType {
        guard let auth = NetworkManager.shared.configuration.clientAuth else {
            fatalError("Client Auth not configured!. Use NetworkManager.configuration to set proper ClientAuthType")
        }
        return auth
    }
    
    //new auth methods
    public func loginAndMigrate(usingViewController viewController: UIViewController, completion: @escaping (Error?) -> Void) {
        newOauth?.loginAndMigrate(usingViewController: viewController, completion: completion)
    }

    public func isMigrated() -> Bool {
        if isAppTriglavDrajv() {
            let newOauthAuthorized = newOauth?.isLoggedIn() == true
            return newOauthAuthorized
        }
        else {
            return false
        }
    }
    /// Returns true if user passed authentification and has all authorization tokens
    public var authorized: Bool {
        let oldAuthAuthorized = clientAuth.isAuthorized
        let newOauthAuthorized = newOauth?.isLoggedIn() == true
        
        if isAppTriglavDrajv() {
            //so authorizovany bud podla stareho alebo noveho authu
            return oldAuthAuthorized || newOauthAuthorized
        }
        else {
            return oldAuthAuthorized
        }
        
    }

    //TODO: Toto tu nema co robit. Auth doda len token a riesi refresh token. userId uz ide z naseho api a ma byt mimo authu!
    /// Identifier of user
    public var userId: String? {
        if isAppTriglavDrajv() {
            if newOauth?.isLoggedIn() == true {
                return newOauth?.userId
            }
            else {
                return clientAuth.userId
            }
        }
        else {
            return clientAuth.userId
        }
    }

    //TODO: to iste ^^^
    /// Security user identifier. Used in authorization for other services (like DrivingModule). Needs to be updated regularly.
    public var secureUserId: String? {
        if isAppTriglavDrajv() {
            if newOauth?.isLoggedIn() == true {
                return newOauth?.secureUserId
            }
            else {
                return clientAuth.secureUserId
            }
        }
        else {
            return clientAuth.secureUserId
        }
    }

    private let accessTokenSemaphore = DispatchSemaphore(value: 1)

    private lazy var accessTokenRequestQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "\(DispatchQueue.labelPrefix).at", qos: .userInitiated)
        return queue
    }()

    private init() {
        
        if isAppTriglavDrajv() {
            let params = configurationForNewTriglavOauth()
            self.newOauth = OauthClientAuth(oauthConfigurationurl: params.url, clientId: params.clientId, redirectUrl: params.callbackUrl)
        }
    }

    /// Clears all user related authentification data and URL cache. Sends notification with Notification.Name.userLoggedOut after all data are cleared.
    public func logout() {
        if isAppTriglavDrajv() {
            if newOauth?.isLoggedIn() == true {
                newOauth?.logout()
            }
            else {
                clientAuth.logout()
            }
        }
        else {
            clientAuth.logout()
            
            
            URLCache.shared.removeAllCachedResponses()
            URLCache.shared.diskCapacity = 0
            URLCache.shared.memoryCapacity = 0
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            }
        }
        
        
        NotificationCenter.default.post(name: .userLoggedOut, object: nil)
    }


    /// Provides access token for private API requests.
    /// - If user pass authentification and access token is valid, forwardTokens block is called immediately.
    /// - Automaticly try to refresh accessToken with refresh token. Returns error if not successful.
    /// - Parameter forwardTokens: completion block with accessToken or error
    /// - Returns: AccessToken or Error by forwardTokens block
    public func accessToken(force: Bool = false, forwardTokens: @escaping (_ accessToken: String?, _ error: Error?) -> ()) {
        guard authorized else {
            //TODO: Aj by som tu dal ze fatalError ale zistil som ze je bezna prax v apke volat API aj ked nie sme prihlaseny. To nie je dobre.
            print("Trying to performing API request without authorization")
            forwardTokens(nil, AuthError())
            return
        }
        //vrchny test len povie ci sme jednou z authou prihlaseny, lae nevieme ktorym. Tu si to rozdelime.
        if newOauth?.isLoggedIn() == true && isAppTriglavDrajv() {
            //self.accessTokenSemaphore.wait()
            newOauth?.accessToken(force: force) { accessToken, error in
                forwardTokens(accessToken, error)
                //self?.accessTokenSemaphore.signal()
            }
        }
        else {
            //using sempahores here to allow access the request resources only once!
            //We do this in a background thread to avoid apps freezes
            accessTokenRequestQueue.async { [weak self] in
                guard let self = self else { return }
                self.accessTokenSemaphore.wait()
                if let token = self.clientAuth.accessToken, force == false {
                    DispatchQueue.main.async {
                        forwardTokens(token, nil)
                    }
                    self.accessTokenSemaphore.signal()
                } else {
                    self.clientAuth.refreshAccessToken { [weak self] result in
                        switch result {
                        case let .success(token):
                            forwardTokens(token, nil)
                        case let .failure(error):
                            forwardTokens(nil, error)
                        }
                        self?.accessTokenSemaphore.signal()
                    }
                }
            }
        }
    }
    
    //TODO: Toto je sprosty hack. Ale do 12.12. veci musia byt hotove a na vacsi refaktor nie je teraz cas.
    private func isAppTriglavDrajv() -> Bool {
        if let bundleId = Bundle.main.bundleIdentifier {
            if bundleId == "com.sygic.triglav" ||
                bundleId == "si.triglav.drajv.tst" ||
                bundleId == "si.triglav.drajv.qa" ||
                bundleId == "si.triglav.drajv"
            {
                return true
            }
        }
        
        return false
    }
    
    //TODO: ako hore. Toto by malo byt v apke, nie v plistoch, a malo by sa to dat do initu. Ale, objekt je singleton, a na refactor nie je cas.
    private func configurationForNewTriglavOauth() -> (url: String, clientId: String, callbackUrl: String) {
        if let bundleId = Bundle.main.bundleIdentifier {
            //DEV
            if bundleId == "com.sygic.triglav" {
                return (
                    //Juraj: sice mame definovane ale naprd. lebo tu chceme mat test
                    /*
                    "https://login-dev.triglav.si/adb2ctriglavdev.onmicrosoft.com/v2.0/.well-known/openid-configuration",
                    "be7ab342-65da-4205-89c6-76472d414b8f",
                    "si.triglav.drajv.dev://login/callback"
                     */
                    //test
                    "https://login-test.triglav.si/adb2ctriglavtest.onmicrosoft.com/v2.0/.well-known/openid-configuration",
                    "52145f71-6409-43fa-b815-028debd3efc5",
                    "si.triglav.drajv.test://login/callback"
                )
            }
            //TEST
            else if bundleId == "si.triglav.drajv.tst" {
                return (
                    "https://login-test.triglav.si/adb2ctriglavtest.onmicrosoft.com/v2.0/.well-known/openid-configuration",
                    "52145f71-6409-43fa-b815-028debd3efc5",
                    "si.triglav.drajv.test://login/callback"
                )
            }
            //QA
            else if bundleId == "si.triglav.drajv.qa" {
                return (
                    "https://login-qa.triglav.si/adb2ctriglavqa.onmicrosoft.com/v2.0/.well-known/openid-configuration",
                    "d39f0cc8-7313-4ae5-9b9e-c4f8dc1f4db0",
                    "si.triglav.drajv.qa://login/callback"
                )
            }
            //PROD
            else if bundleId == "si.triglav.drajv" {
                return (
                    "https://login.triglav.si/adb2ctriglav.onmicrosoft.com/v2.0/.well-known/openid-configuration",
                    "8f92be92-9d48-4888-995b-a881c6684321",
                    "si.triglav.drajv://login/callback"
                )
            }
            else {
                //default dev
                return (
                    "https://login-dev.triglav.si/adb2ctriglavdev.onmicrosoft.com/v2.0/.well-known/openid-configuration",
                    "be7ab342-65da-4205-89c6-76472d414b8f",
                    "si.triglav.drajv.dev://login/callback"
                )
            }
        }
        else {
            //return dev as default
            return (
                "https://login-dev.triglav.si/adb2ctriglavdev.onmicrosoft.com/v2.0/.well-known/openid-configuration",
                "be7ab342-65da-4205-89c6-76472d414b8f",
                "si.triglav.drajv.dev://login/callback"
            )
        }
            
        //url
        //client id
        //callbackUrl
    }
}

public extension Auth {
    //TODO: Na vsetky pripady jedna chyba? Radost hladat problem ked sa nieco pokazi.
    struct AuthError: Error {
        var localizedDescription: String { "unauthorized" }
    }
}
