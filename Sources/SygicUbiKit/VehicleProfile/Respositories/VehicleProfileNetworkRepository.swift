import Foundation

// MARK: - VehicleProfileNetworkRepository

class VehicleProfileNetworkRepository: VehicleProfileNetworkRepositoryType {
    private let networkManager = NetworkManager.shared

    func loadProfiles(completion: @escaping (Result<VehicleProfileDataType, Error>) -> ()) {
        //TODO: Make networkFetch here

        networkManager.requestAPI(ApiRouterVehicleProfile.listVehicles) { (result: Result<NetworkVehicleProfile, Error>) in
            switch result {
            case let .success(profile):
                completion(.success(profile))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func createVehicle(with profile: NetworkVehicle, completion: @escaping (Result<NetworkVehicle, Error>) -> ()) {
        networkManager.requestAPI(ApiRouterVehicleProfile.createVehicle, postData: profile.postData()) { (result: Result<NetworkPostResponseVechileData?, Error>) in
            switch result {
            case let .success(vehicle):
                let networkVehicle: NetworkVehicle = NetworkVehicle(postDataResonse: vehicle!)
                completion(.success(networkVehicle))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func patchVehicle(with profile: NetworkVehicle, completion: @escaping (Result<NetworkPostResponseVechileData, Error>) -> ()) {
        networkManager.requestAPI(ApiRouterVehicleProfile.updateVehicle(profile.publicId), postData: profile.patchData()) { (result: Result<NetworkPostResponseVechileData?, Error>) in
            switch result {
            case let .success(vehicle):
                completion(.success(vehicle!))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

private extension VehicleProfileNetworkRepository {
    func loadMockList() -> VehicleProfileDataType? {
        guard let url = Bundle(for: VehicleProfileNetworkRepository.self).url(forResource: "VehiclesListMock", withExtension: "json") else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        do {
            guard let listModel: NetworkVehicleProfile = try NetworkManager.shared.decodeData(data: data) else {
                return nil
            }
            return listModel
        } catch {
            return nil
        }
    }
}
