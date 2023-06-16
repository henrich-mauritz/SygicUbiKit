import Foundation

// MARK: - VehicleListViewModelDelegate

public protocol VehicleListViewModelDelegate: AnyObject {
    func didUpdate(viewModel: VehicleListViewModel)
    func didFailUpdate(viewModel: VehicleListViewModel, with error: Error)
}

// MARK: - VehicleListType

public enum VehicleListType {
    case active
    case all
}

// MARK: - VehicleListViewModel

public class VehicleListViewModel: InjectableType {
    public weak var delegate: VehicleListViewModelDelegate?

    private var model: VehicleProfileDataType?
    private lazy var repository: VehicleProfileRepositoryType = container.resolveVehicleProfileRepo()
    private var _selectedVehicleIndex: Int?
    public var selectedVehicleIndex: Int {
        set {
            _selectedVehicleIndex = newValue
        }
        get {
            if _selectedVehicleIndex == nil {
                var index = 0
                if listType == .active {
                    index = model?.vehicles.filter { $0.state == .active }.firstIndex(where: { $0.isSelectedForDriving == true }) ?? 0
                } else {
                    index = model?.vehicles.firstIndex(where: { $0.isSelectedForDriving == true }) ?? 0
                }
                return index
            }
            return _selectedVehicleIndex!
        }
    }

    private var vehicleList: [NetworkVehicle] {
        if listType == .all {
            return model?.vehicles ?? []
        }

        return model?.vehicles.filter { $0.state == .active } ?? []
    }

    let listType: VehicleListType

    init(with vehicleLisType: VehicleListType = .all) {
        listType = vehicleLisType
    }

    public var maxVehiclePerUser: Int {
        repository.configuration?.maxCountPerUser ?? 10
    }

    /// Loads vehicles, this method will ask the repository to make a fetch or returns from cache if the the cleanCahce parameter is false
    /// - Parameter cleanCache: should clean cache or return cahced ones
    public func loadVehicles(cleanCache: Bool) {
        repository.loadProfiles(cleanCache: cleanCache) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.model = data
                self.delegate?.didUpdate(viewModel: self)
            case let .failure(error):
                self.delegate?.didFailUpdate(viewModel: self, with: error)
            }
        }
    }

    /// Returns the numbers of registered vehicles in the array
    /// - Returns: number of vehicles
    public func numberOfRegisteredVehicles() -> Int {
        return vehicleList.count
    }

    /// returns a netwokr vechile, could except if the index is invalid
    /// - Parameter index: index of the vehicle in the array
    /// - Returns: NetworkVehicle
    public func vehicle(at index: Int) -> NetworkVehicle? {
        guard vehicleList.count > 0 else { return nil }
        return vehicleList[index]
    }

    public func setVehicleAsDefault(_ vehicle: VehicleProfileType) {
        //get current default and put to false then
        //take vehicle and set it to true
        if let currentDefault = model?.vehicles.filter({ $0.isSelectedForDriving ?? false}).first {
            currentDefault.isSelectedForDriving = false
        }
        vehicle.isSelectedForDriving = true
        UserDefaults.standard.set(vehicle.publicId, forKey: VehicleProfileModule.kSelectedVehcileIdForDriving)
        repository.sync()
    }

    /// This method only changes the currentSelection parameter to be used by other componets,
    /// like the car list picker, this does not changes the current default selection for driving
    /// if not found it just leaves nil
    /// - Parameter vehicle: the vehicle to set
    public func setSelectedListVehicle(with vehicle: VehicleProfileType) {
        if let index = vehicleList.firstIndex(where: { $0.publicId == vehicle.publicId }) {
            selectedVehicleIndex = index
        }
    }
}
