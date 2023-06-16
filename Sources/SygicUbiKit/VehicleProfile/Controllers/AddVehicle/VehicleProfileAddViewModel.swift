import Foundation

// MARK: - VehicleProfileAddViewModel

class VehicleProfileAddViewModel: VehicleProfileViewModel, InjectableType {
    private lazy var repo = container.resolveVehicleProfileRepo()

    public var numberOfVehicles: Int {
        repo.storedVehicles.count
    }

    init() {
        let newVehicle = NetworkVehicle(name: "", type: .unknown, state: .inactive)
        super.init(with: newVehicle)
    }

    func maxAllowedVehicles(completion: @escaping ((Int) -> ())) {
        ConfigurationModule.fetchConfiguration { result in
            switch result {
            case let .success(config):
                let maxCountPerUser = config.maxTotalVehicleCountPerUser
                completion(maxCountPerUser ?? 10)
            case .failure(_):
                completion(10) //default
            }
        }
    }

    func addVehile(completion: @escaping (VehicleProfileAddEditError?) -> ()) {
        repo.createVehicle(with: vehicle) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                completion(nil)
            case let .failure(error):
                guard let error = error as? NetworkError else {
                    completion(.unknown)
                    return
                }
                self.name = ""
                let addError = VehicleProfileAddEditError(with: error)
                completion(addError)
            }
        }
    }
}
