import Foundation

//MARK: - Utils

public extension NetworkManager {
    func newAppVersionAvailable(completion: @escaping (_ updateData: AppUpdateData?) -> ()) {
        self.requestAPI(ApiRouterSYNetworking.endpointUpdateAvaiable) { (result: Result<AppUpdateData, Error>) in
            switch result {
            case let .success(data):
                completion(data)
            case .failure(_):
                completion(nil)
            }
        }
    }
}
