import Foundation
import SygicMaps

//stupid hack, because maps module define protocol, but we don't have that protocol in commonSDK and we don't want to make our commonSDK dependent on sygic map sdk. Sygic maps should move SYAuthProvider to auth lib. (why the hell it is in maps?!)
class SygicAuthProxy: NSObject, SYAuthProvider {
    func buildHeaders(completion: @escaping SYOnlineBuildHeadersCompletionBlock) {
        SygicAuthorization.shared.buildHeadersForLibs(completion: completion)
    }
    
    func notifyAuthenticationRejected() {
        //nothing
    }
}


public class SygicMapsInitializer {
    public class func isSDKInitialized() -> Bool {
        return SYContext.isInitialized()
    }

    private static let shared = SygicMapsInitializer()
    
    private var authProxy: SygicAuthProxy?

    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)

    private lazy var sygicMapsInitQueue: DispatchQueue = {
        DispatchQueue(label: "com.sygicKitModules.sygicMapsInit", qos: .default)
    }()

    private init() {}

    public static func initializeSDK(completion: ((_ success: Bool) -> ())? = nil) {
        //TODO: chalpi, apka moze byt zavysla na libke, ale libka nemoze byt zavysla na apke. Toto je zle. Tieto parametre mali ist na vstup initializeSDK(clientId, secret, licenseKey)
        guard let clientId = Bundle.main.infoDictionary?["SDK_CLIENT_ID"] as? String,
              let secret = Bundle.main.infoDictionary?["SDK_APP_SECRET"] as? String,
              //Driving jwt je licencia pre vsetky sygic produkty, toto vzniklo ako sygic postupne presiel na novy licencny model. Zmenou maps sdk z 19.x na 21.x sme dostali aj iny licencny model.
              //TODO: Renaning..driving jwt je dost zly nazov.
              let licenseKey = Bundle.main.infoDictionary?["DRIVING_JWT"] as? String
        else {
            fatalError("!!! Missing SDK_CLIENT_ID or SDK_APP_SECRET in main bundle infoDictionary")
        }
        SygicMapsInitializer.shared.setupSygicMapsSDK(clientId, secret: secret, licenseKey: licenseKey, completion: completion)
    }

    private func setupSygicMapsSDK(_ clientId: String, secret: String, licenseKey: String, completion: ((_ success: Bool) -> ())?) {
        sygicMapsInitQueue.async {
            self.semaphore.wait()
            guard !SYContext.isInitialized() else {
                self.semaphore.signal()
                DispatchQueue.main.async {
                    completion?(true)
                }
                return
            }
            let s1 = [
                "app_key": clientId,
             //   "app_secret": secret,
            ]
            
            let s2 = [ "license_key" : licenseKey]
            let configSDK = [
                "Authentication": s1,
                "License" : s2,
                "MapReaderSettings": ["startup_online_maps_enabled": true],
            ] as [String: Any]
            
            
            let contextRequest = SYContextInitRequest(configuration: configSDK)
            self.authProxy = SygicAuthProxy()
            contextRequest.authProvider = self.authProxy
            contextRequest.authProvider = SygicAuthorization.shared as? SYAuthProvider
            SYContext.initWithRequest(contextRequest) {[weak self] result, _ in
                guard let weakSelf = self else { return }
                print("SygicMaps SDK init: \(result)")
                NotificationCenter.default.addObserver(weakSelf, selector: #selector(Self.applicationWillTerminate(notification:)), name: UIApplication.willTerminateNotification, object: nil)
                weakSelf.semaphore.signal()
                DispatchQueue.main.async {
                    completion?(result == .success)
                }
            }
        }
    }

    @objc
private func applicationWillTerminate(notification: Notification) {
        guard SYContext.isInitialized() else { return }
        SYContext.terminate()
    }
}
