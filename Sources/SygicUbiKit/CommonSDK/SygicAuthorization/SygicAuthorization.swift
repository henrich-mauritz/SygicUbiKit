//
//  SygicAuthorization.swift
//  CommonSDK
//
//  Created by Juraj Antas on 20/03/2023.
//

import Foundation
import UIKit
import SygicAuth

//TODO:    why the hell I have here missing type?! because it is defined in maps sdk..crap
@objc public class SygicAuthorization : NSObject, SYAuthDelegate /*, SYAuthProvider*/ {
    
    public static let shared = SygicAuthorization()
    
    var auth : SYAuth? = nil
    var urlSession : URLSession? = nil
   
    @objc public func getAuth() -> SYAuth? {
        return auth
    }
    
    @objc public func getAuthToken(completion: @escaping (String?) -> Void )  {
        guard let auth = self.auth else {
            completion(nil)
            return
        }
        
        auth.buildHeaders { result, outHeaders, error in
            if error == nil {
                completion(outHeaders?["Authorization"])
            }
            else {
                completion(nil)
            }
        }
    }
    //preco? lebo potrebujem presne callback ako maju mapy a driving lib definovany. presna definicia je v SYAuthProvider ale nechcem mat tu zavislost na map sdk.
    @objc public func buildHeadersForLibs(completion: @escaping ([String:String]?, NSError?) -> Void ) {
        guard let auth = self.auth else {
            completion(nil, NSError(domain: "auth not created", code: 60007))
            return
        }
        
        auth.buildHeaders { result, outHeaders, error in
            if error == nil {
                completion(outHeaders, nil)
            }
            else {
                completion(nil, error as? NSError)
            }
        }
    }
    
    //preco sync metoda? lebo SOSAssistance, a vobec cely APIRouter je navrhnuty divne. Ako keby sa token nemusel refreshovat.
    //vrati komplet Bearer gsfngsdngdmfsng...
    public func getAuthTokenSync() -> String? {
        guard let auth = self.auth else {
            return nil
        }
        
        let semaphore = DispatchSemaphore(value: 0)
    
        var resultBearer: String?

        auth.buildHeaders { result, outHeaders, error in
            if error == nil {
                resultBearer = outHeaders?["Authorization"]
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        return resultBearer
    }
    
    private override init() {
        super.init()
        configureAuth()
    }
    
    func configureAuth() {
        
        guard let clientId = Bundle.main.infoDictionary?["SDK_CLIENT_ID"] as? String,
              let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        else {
            fatalError("Auth values must exist! What's the pont without them.")
        }
        
        let urlConfig = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: urlConfig)
        //production url of auth
        let authUrl = URL(string:  "https://auth.api.sygic.com/oauth2/token")!
 
        //If the value is nil, wait and get the value again later. This happens, for example, after the device has been restarted but before the user has unlocked the device.
        //TODO: toto by sa mozno zislo aj inde.
        let deviceIdKey = "DeviceIdKey"
        let service = "Device"
        var deviceData = try? Keychain.get(account: deviceIdKey, service: service)
        var deviceId: String?
        
        if deviceData == nil {
            deviceId = UIDevice.current.identifierForVendor?.uuidString
            if let deviceId = deviceId {
                do {
                    try Keychain.set(value: Data(deviceId.utf8), account: deviceIdKey, service: service)
                }
                catch {
                    //not sure what to do here. Probably nothing. Next time we try again.
                }
            }
        }
        
        
        if let deviceId = deviceId {
            let authConfig = SYAuthConfig(url: authUrl, appId: bundleId, clientId: clientId, clientSecret: nil, deviceCode: deviceId)
            self.auth = SYAuth(config: authConfig, network: self, storage: self, queue: DispatchQueue.global(qos: .userInteractive), delegate: self)
        }
        else {
            //TODO: can happen when device restarted but user not yet unlocked device. Can app run? yes.
        }
    }
    
    public func didChangeState(_ state: SYAuthState) {
        //nothing
    }
    
    public func didSignOutWithoutRequest() {
        //TODO: a co tu mam robit? Toto nie je login uzivatela ale login sluzieb. Musime sa znova prihlasit..
    }
}

extension SygicAuthorization : SYAuthNetworkProvider {
    public func sendRequest(_ request: URLRequest, completion: @escaping SYAuthSendRequestCompletion) {
        guard let urlSession = self.urlSession else {
            let error = NSError(domain: "url session not initialized", code: 60006, userInfo: nil)
            completion(nil,nil,error)
            return
        }
        
        let dataTask = urlSession.dataTask(with: request) { data, response, error in
            completion(data, response,error)
        }
        
        dataTask.resume()
        
    }
    
    
}

extension SygicAuthorization : SYAuthStorageProvider {
    public func string(forKey key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    public func setString(_ string: String?, forKey key: String) {
        if (string == nil) {
            UserDefaults.standard.removeObject(forKey: key)
        }
        else {
            UserDefaults.standard.set(string, forKey: key)
        }
    }
    
}

