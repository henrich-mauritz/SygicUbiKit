import Foundation

class DiscountCodesProgressNetworkRepository: DiscountCodesNewtorkRepositoryType {
    let networkManager = NetworkManager.shared

    func loadDiscountCodeData(for vehicleId: String, completion: @escaping (Result<DiscountCodesDataProtocol, Error>) -> ()) {
        let filter = ApiRouterDiscounts.DiscountRequestData.Filter()
        let requestData = ApiRouterDiscounts.DiscountRequestData(filter: filter)
        networkManager.requestAPI(ApiRouterDiscounts.endpointDiscountCodes(vehicleId, filterData: requestData),
                                  postData: requestData) {(result: Result<NetworkDiscountCodesData?, Error>) in
            switch result {
            case let .success(data):
                guard let data = data else {
                    completion(.failure(NetworkError.unknown))
                    return
                }
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func loadMoreDiscountCodeData(for page: Int, with vehicleId: String, completion: @escaping (Result<DiscountCodesDataProtocol, Error>) -> ()) {
        var filter = ApiRouterDiscounts.DiscountRequestData.Filter()
        filter.setPageNumber(page: page)
        let requestData = ApiRouterDiscounts.DiscountRequestData(filter: filter)
        networkManager.requestAPI(ApiRouterDiscounts.endpointDiscountCodes(vehicleId, filterData: requestData),
                                  postData: requestData) {(result: Result<NetworkDiscountCodesData?, Error>) in
            switch result {
            case let .success(data):
                guard let data = data else {
                    completion(.failure(NetworkError.unknown))
                    return
                }
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func loadHowToData(for type: VehicleType, completion: @escaping (Result<DiscountHowToDataProtocol, Error>) -> ()) {
        networkManager.requestAPI(ApiRouterDiscounts.endpointHowToInstructions(type)) { (result: Result<DiscountHowToData, Error>) in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func loadProgressData(for vehicleId: String, _ completion: @escaping (Result<DiscountProgressDataProtocol, Error>) -> ()) {
        networkManager.requestAPI(ApiRouterDiscounts.endpointDiscountProgress(vehicleId)) { (result: Result<DiscountProgressData, Error>) in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
