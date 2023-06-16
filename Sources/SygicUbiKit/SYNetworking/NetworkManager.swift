import Foundation
import UIKit

public class NetworkManager {
    public static let shared = NetworkManager()

    public var configuration: NetworkManagerConfigurable = DefaultConfiguration()

    public var unauthorizedNotification: Notification.Name { Notification.Name("SYNetworkManagerUnauhtorizedNotification") }

    public let session = URLSession(configuration: .default)

    public let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    public var debugLogs: Bool = ADASDebug.enabled

    public typealias ResponseBlock = (Result<Data, Error>) -> ()

    public let errorDomain: String = "NetworkManagerURLSessionResponse"

    private init() {
        ReachabilityManager.shared.setupReachability()
    }

    private struct SomeCodable: Codable {
        func getData() -> Data {
            Data()
        }
    }
    
    func generateDictForLogout(errorCode: Int, errorText: String, fileLineFunction: String) -> [String: String] {
        //add some common items
        
        var d: [String: String] = [:]
        d["eventDate"] = dateFormatter.string(from: Date())
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            d["deviceId"] = deviceId
        }
    
        d["where"] = fileLineFunction
        d["errorCode"] = String(errorCode)
        d["errorDescription"] = errorText
    
        return d
    }

    public func requestAPI<ResponseType: Codable>(_ endpoint: ApiEndpoints, completion: @escaping (Result<ResponseType, Error>) -> ()) {
        let some: SomeCodable? = nil
        requestAPI(endpoint, postData: some) { (result: Result<ResponseType?, Error>) in
            switch result {
            case let .success(data):
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(NetworkError.decodingError))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func requestAPI(_ endpoint: ApiEndpoints, completion: @escaping (Error?) -> ()) {
        let some: SomeCodable? = nil
        requestAPI(endpoint, postData: some) { (result: Result<SomeCodable?, Error>) in
            switch result {
            case .success:
                completion(nil)
            case let .failure(error):
                completion(error)
            }
        }
    }

    public func requestAPI<PostType: Codable, ResponseType: Codable>(_ endpoint: ApiEndpoints, postData: PostType?, completion: @escaping (Result<ResponseType?, Error>) -> ()) {
        var encodedData: Data?
        if let toEncode = postData {
            do {
                encodedData = try encodeData(data: toEncode)
            } catch {
                completion(.failure(error))
                return
            }
        }
        requestData(from: endpoint, postData: encodedData) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                if data.isEmpty {
                    DispatchQueue.main.async {
                        completion(.success(nil))
                    }
                    return
                }
                do {
                    let decodedData: ResponseType? = try self.decodeData(data: data)
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                } catch let decodeError {
                    if self.debugLogs {
                        print("--------------PARSING-Error-------------\n\(decodeError))")
                    }
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingError))
                    }
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    public func requestData(from endpoint: ApiEndpoints, postData: Data? = nil, block: @escaping ResponseBlock) {
        if endpoint.requieresAuth {
            if let requestToken = endpoint.authToken, let request = self.apiRequest(for: endpoint, token: requestToken, bodyData: postData) {
                self.sendRequest(urlRequest: request, block: block)
            } else {
                Auth.shared.accessToken { [weak self] token, error in
                    guard let weakSelf = self else { return }
                    if let error = error, token == nil {
                        //TODO: tento kod nevie dobre rozhodnut ci odhlasit uzivatela alebo nie.
                        //dovodom je ze AppAuth si definuje vlastne chyby
                        //odhlas uzivatela! ale iba ked je to realna chyba a nie chyba ze nemame internet.
                        //budeme odhlasovat len ked pride 400, 401, pre AppAuth si to budeme musiet checknut..
                        //lenze tu uz nevieme dostat httpresponse a nevieme pozriet http code.
                        //Takze nakoniec to bude takto:
                        var returnError: NSError = error as NSError
                        //v pripade app authu mame chybu v undelaying error
                        var willLogout: Bool = true
                        //appAuth error code, this means no connection
                        if (error as NSError).code == -5 || (error as NSError).code == -6 {
                            willLogout = false
                            //lebo potrebujem aby apka tvrdila ze nemame internety
                            returnError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet);
                            //returnError = NetworkError.noInternetConnection
                        }
                        //our error code
                        let networkError = NetworkError.error(from: error as NSError)
                        if networkError == .noInternetConnection || networkError == .serverUnavailable {
                            willLogout = false
                        }
                        
                        if willLogout {
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else {return}
                                Auth.shared.logout()
                                
                                let fileLineFunction = "\(#fileID), #:\(#line) \(#function)"
                                let dict = self.generateDictForLogout(errorCode: (error as NSError).code, errorText: (error as NSError).localizedDescription, fileLineFunction: fileLineFunction)
                                NotificationCenter.default.post(name: NetworkManager.shared.unauthorizedNotification, object: nil, userInfo: dict)
                            }
                        }
                        block(.failure(returnError))
                        
                        return
                    }
                    guard let accessToken = token, let request = weakSelf.apiRequest(for: endpoint, token: accessToken, bodyData: postData) else { return }
                    weakSelf.sendRequest(urlRequest: request, block: block)
                }
            }
        } else {
            guard let request = apiRequest(for: endpoint, bodyData: postData) else { return }
            sendRequest(urlRequest: request, block: block)
        }
    }

    public func sendRequest(urlRequest: URLRequest, block: @escaping ResponseBlock) {
        //check for internet connection first
        if ReachabilityManager.shared.status == .unreachable {
            block(.failure(NetworkError.noInternetConnection))
            return
        }
        if debugLogs {
            print("SENDING: " + urlRequest.url!.absoluteString)
        }
        sessionDataRequest(with: urlRequest) { result in
            switch result {
            case .success(_):
                block(result)
            case let .failure(error):
                guard let error = error as? NetworkError else {
                    block(result)
                    return
                }
                if error.httpErrorCode == 403,
                   let userInfo = error.httpUserInfo,
                   let data = userInfo["data"] as? [String: Any],
                   let recommendedAction = data["recommendedAction"] as? String,
                   recommendedAction == "signOut" {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {return}
                        Auth.shared.logout()
                        
                        let fileLineFunction = "\(#fileID), #:\(#line) \(#function)"
                        let dict = self.generateDictForLogout(errorCode: error.httpErrorCode ?? 0, errorText: error.localizedDescription, fileLineFunction: fileLineFunction)
                        NotificationCenter.default.post(name: NetworkManager.shared.unauthorizedNotification, object: error, userInfo: dict)
                    }
                }
                   
                else if error.httpErrorCode == 401 {
                    //Need to make refresh token
                    //If it fails again It will autologout from within
                    Auth.shared.accessToken(force: true) {[weak self] token, error in
                        guard let self = self else { return }
                        if let token = token, error == nil {
                            var updatedRequest = urlRequest
                            updatedRequest.setValue(token, forHTTPHeaderField: "Authorization")
                            self.sessionDataRequest(with: updatedRequest, block: block)
                        } else {
                            block(.failure(NetworkError.invalidToken))
                            return
                        }
                    }
                } else {
                    block(.failure(error))
                }
            }
        }
    }

    private func sessionDataRequest(with urlRequest: URLRequest, block: @escaping ResponseBlock) {
        session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            let httpResponse = response as? HTTPURLResponse
            if let data = data, httpResponse?.statusCode == 200 {
                block(.success(data))
            } else {
                guard let httpResponse = httpResponse else {
                    block(.failure(NetworkError.error(from: error as NSError?)))
                    return
                }
                if httpResponse.statusCode == 401 {
                    block(.failure(NetworkError.httpError(code: httpResponse.statusCode)))
                    return
                }
                guard let data = data else {
                    block(.failure(NetworkError.httpError(code: httpResponse.statusCode)))
                    return
                }
                do {
                    let userInfo = try self.decodeError(data: data)
                    block(.failure(NetworkError.httpError(code: httpResponse.statusCode, userInfo: userInfo)))
                } catch _ {
                    block(.failure(NetworkError.httpError(code: httpResponse.statusCode)))
                }
            }
        }.resume()
    }

    public func encodeData<T: Codable>(data: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 //.formatted(self.dateFormatter)
        let encodedData = try encoder.encode(data)
        if debugLogs {
            print("--------------ENCODED--------------\n\(String(data: encodedData, encoding: .utf8) ?? "encoded error")")
        }
        return encodedData
    }

    public func decodeData<T: Codable>(data: Data) throws -> T {
        if debugLogs {
            print("--------------DECODING--------------\n\(String(data: data, encoding: .utf8) ?? "data error")")
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let decodedData = try decoder.decode(T.self, from: data)
        return decodedData
    }

    public func decodeError(data: Data) throws -> [String: AnyObject] {
        if debugLogs {
            print("--------------DECODING-Error-------------\n\(String(data: data, encoding: .utf8) ?? "data error")")
        }
        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let jsonDicResult = jsonResult as? [String: AnyObject] else {
            return [:]
        }
        return jsonDicResult
    }

    public func languageLocaleHeaderValue() -> String {
        if let preferredLanguage = CommonConfigurator.shared.configuration.preferredLanguage {
            return preferredLanguage
        }
        let defaultLanguage = "en"
        guard let preferedLanguage = Locale.current.languageCode else { return defaultLanguage }
        let supportedLanguages = configuration.supportedLanguages
        if supportedLanguages.count > 0 {
            if supportedLanguages.contains(preferedLanguage) {
                return preferedLanguage
            } else {
                return defaultLanguage
            }
        } else {
            return preferedLanguage
        }
    }

    private func apiRequest(for endpoint: ApiEndpoints, token: String? = nil, bodyData: Data? = nil) -> URLRequest? {
        guard let url = endpoint.url else { return nil }
        var request = URLRequest(url: url) //, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 5)
        request.httpMethod = endpoint.requestMethod
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        request.addValue(languageLocaleHeaderValue(), forHTTPHeaderField: "Accept-Language")
        request.addValue(configuration.userAgent, forHTTPHeaderField: "User-Agent")
        if endpoint.requieresAuth {
            guard let token = token else {
                fatalError("Requesting private API \'\(endpoint.endpoint)\' without auth token")
            }
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }
        if let additionalHeaders = endpoint.additionalRequestHeaders {
            for key in additionalHeaders.keys {
                if let val = additionalHeaders[key] {
                    request.addValue(val, forHTTPHeaderField: key)
                }
            }
        }
        if let additionalHeaders = configuration.additionalRequestHeaders {
            for key in additionalHeaders.keys {
                if let val = additionalHeaders[key] {
                    request.addValue(val, forHTTPHeaderField: key)
                }
            }
        }
        if endpoint.requestMethod == "POST" || endpoint.requestMethod == "PUT" || endpoint.requestMethod == "PATCH" {
            request.httpBody = bodyData
        }
        return request
    }
}
