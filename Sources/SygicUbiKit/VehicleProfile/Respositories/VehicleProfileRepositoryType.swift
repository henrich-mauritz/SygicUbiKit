import Foundation

// MARK: - VehicleProfileRepositoryType

public protocol VehicleProfileRepositoryType {
    var storedVehicles: [NetworkVehicle] { get }
    var activeVehicles: [NetworkVehicle] { get }
    var configuration: VehicleProfileConfiguration? { get }
    func loadProfiles(cleanCache: Bool, completion: @escaping (Result<VehicleProfileDataType, Error>) -> ())
    func createVehicle(with profile: NetworkVehicle, completion: @escaping (Result<VehicleProfileType, Error>) -> ())
    func patchVehicle(with profile: NetworkVehicle, completion: @escaping (Result<VehicleProfileType, Error>) -> ())
    func sync()
    func cleanAllData()
}

// MARK: - VehicleProfileCacheRepositoryType

public protocol VehicleProfileCacheRepositoryType {
    func loadProfiles() -> VehicleProfileDataType?
    func update(with profile: VehicleProfileDataType)
    func addVehicle(with profile: NetworkVehicle)
    func patchVehicle(with profile: NetworkVehicle, updatedProfile: NetworkPostResponseVechileData)
    func cleanCache()
    func sync()
}

// MARK: - VehicleProfileNetworkRepositoryType

public protocol VehicleProfileNetworkRepositoryType {
    func loadProfiles(completion: @escaping (Result<VehicleProfileDataType, Error>) -> ())
    func createVehicle(with profile: NetworkVehicle, completion: @escaping (Result<NetworkVehicle, Error>) -> ())
    func patchVehicle(with profile: NetworkVehicle, completion: @escaping (Result<NetworkPostResponseVechileData, Error>) -> ())
}

// MARK: - VehicleProfileRepository

public class VehicleProfileRepository: VehicleProfileRepositoryType, InjectableType {
    private let cacheRepo: VehicleProfileCacheRepositoryType
    private let networkRepo: VehicleProfileNetworkRepositoryType
    public var storedVehicles: [NetworkVehicle] {
        guard let vehicleData = cacheRepo.loadProfiles() else { return [] }
        return vehicleData.vehicles
    }

    public var activeVehicles: [NetworkVehicle] { storedVehicles.filter { $0.state == .active } }

    public var configuration: VehicleProfileConfiguration? {
        return VehicleProfileConfiguration()
    }

    public init(cacheRepo: VehicleProfileCacheRepositoryType, networkRepo: VehicleProfileNetworkRepositoryType) {
        self.cacheRepo = cacheRepo
        self.networkRepo = networkRepo
        ReachabilityManager.shared.setupReachability()
    }

    public func loadProfiles(cleanCache: Bool, completion: @escaping (Result<VehicleProfileDataType, Error>) -> ()) {
        if ReachabilityManager.shared.status == .unreachable {
            if let cachedProfiles = self.cacheRepo.loadProfiles() {
                completion(.success(cachedProfiles))
                return
            }
        }

        if cleanCache {
            cacheRepo.cleanCache()
        }

        if cleanCache == false, let cachedProfiles = self.cacheRepo.loadProfiles() {
            completion(.success(cachedProfiles))
            return
        }
        self.networkRepo.loadProfiles { result in
            switch result {
            case let .success(vehicleProfiles):
                if let selectedVehicleIdForDriving = UserDefaults.standard.string(forKey: VehicleProfileModule.kSelectedVehcileIdForDriving) {
                    let selected = vehicleProfiles.vehicles.filter {
                        $0.publicId == selectedVehicleIdForDriving
                    }
                    if let first = selected.first {
                        first.isSelectedForDriving = true
                    }
                } else { //select the first one on the list
                    if let first = vehicleProfiles.vehicles.first(where: { $0.state == .active }) {
                        first.isSelectedForDriving = true
                        UserDefaults.standard.set(first.publicId, forKey: VehicleProfileModule.kSelectedVehcileIdForDriving)
                    }
                }
                self.cacheRepo.update(with: vehicleProfiles)
                completion(result)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func createVehicle(with profile: NetworkVehicle, completion: @escaping (Result<VehicleProfileType, Error>) -> ()) {
        self.networkRepo.createVehicle(with: profile) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(vehicle):
                self.cacheRepo.addVehicle(with: vehicle)
                completion(.success(vehicle))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func patchVehicle(with profile: NetworkVehicle, completion: @escaping (Result<VehicleProfileType, Error>) -> ()) {
        self.networkRepo.patchVehicle(with: profile) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(updatedProfile):
                self.cacheRepo.patchVehicle(with: profile, updatedProfile: updatedProfile)
                completion(.success(profile))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func sync() {
        cacheRepo.sync()
    }

    public func cleanAllData() {
        cacheRepo.cleanCache()
        UserDefaults.standard.removeObject(forKey: VehicleProfileModule.kSelectedVehcileIdForDriving)
    }
}
