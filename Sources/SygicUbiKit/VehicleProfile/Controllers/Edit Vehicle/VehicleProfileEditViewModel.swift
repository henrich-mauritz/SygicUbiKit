import Foundation

// MARK: - VehicleProfileEditViewModel

class VehicleProfileEditViewModel: VehicleProfileViewModel, InjectableType {
    private lazy var repo = container.resolveVehicleProfileRepo()

    /// In case there is some error when editing we rollback
    var oldName: String
    var oldState: VehicleState
    var canChangeState: Bool {
        guard let selectedForDriving = vehicle.isSelectedForDriving else {
            return true
        }
        return !selectedForDriving
    }

    var hasMoreThanOneVehicle: Bool {
        repo.activeVehicles.count > 1
    }

    override init(with vehicle: NetworkVehicle) {
        oldName = vehicle.name
        oldState = vehicle.state
        super.init(with: vehicle)
    }

    public func editVehcile(completion: @escaping (VehicleProfileAddEditError?) -> ()) {
        repo.patchVehicle(with: vehicle) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                completion(nil)
                NotificationCenter.default.post(name: .vehicleProfileDidToggleVehicleActivation, object: nil, userInfo: nil)
            case let .failure(error):
                self.vehicle.name = self.oldName
                self.vehicle.state = self.oldState
                guard let error = error as? NetworkError else {
                    completion(.unknown)
                    return
                }
                let editError = VehicleProfileAddEditError(with: error)
                completion(editError)
            }
        }
    }
}
