import UIKit

public class DiscountHowToViewModel: DiscountHowToViewModelProtocol, InjectableType {
    public weak var delegate: DiscountsViewModelDelegate?

    public var title: String {
        guard let title = data?.title else { return ""}
        return title
    }

    public var items: [DiscountTerms] {
        guard let items = data?.items else { return [DiscountTerms]() }
        return items
    }

    public private(set) var loading: Bool = false {
        didSet {
            delegate?.viewModelUpdated(self)
        }
    }

    private lazy var vehicleRepository = container.resolveVehicleProfileRepo()

    public var hasMoreThanOneVehicle: Bool {
        vehicleRepository.storedVehicles.count > 1
    }

    public var currentFilteringVehicle: VehicleProfileType

    private var data: DiscountHowToDataProtocol? {
        didSet {
            guard data != nil else { return }
            delegate?.viewModelUpdated(self)
        }
    }

    private lazy var repository = container.resolveDiscountCodeRepo()

    init(with vehicle: VehicleProfileType) {
        self.currentFilteringVehicle = vehicle
    }

    public func reloadData() {
        loading = true
        repository.loadHowToData(for: currentFilteringVehicle.vehicleType) { [weak self] result in
            self?.loading = false
            switch result {
            case let .success(howToData):
                self?.data = howToData
            default:
                break
            }
        }
    }
}
