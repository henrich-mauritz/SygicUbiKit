import UIKit

// MARK: - DiscountProgressViewModelDelegate

public protocol DiscountProgressViewModelDelegate: AnyObject {
    func viewModelUpdated(_ sender: Any)
}

// MARK: - DiscountProgressViewModel

public class DiscountProgressViewModel: DiscountProgressViewModelProtocol, InjectableType {
    public var currentFilteringVehicle: VehicleProfileType

    public var start: DiscountProgressType = .achieved

    public var items: [DiscountProgressChallange] {
        guard let challanges = data?.items else { return [DiscountProgressChallange]() }
        return challanges
    }

    public private(set) var loading: Bool = false {
        didSet {
            delegate?.viewModelUpdated(self)
        }
    }

    public weak var delegate: DiscountProgressViewModelDelegate?

    private lazy var repository = container.resolveDiscountCodeRepo()

    private lazy var vehicleRepository = container.resolveVehicleProfileRepo()
    public var hasMoreThanOneVehicle: Bool {
        vehicleRepository.storedVehicles.count > 1
    }

    private var data: DiscountProgressDataProtocol? {
        didSet {
            guard let dataVal = data else { return }
            let today = Date()
            let maxFiltered = dataVal.items.filter {
                guard let date = $0.date else { return false }
                return date.compare(today) == .orderedAscending
            }.sorted(by: {$0.date!.compare($1.date!) == .orderedAscending })
            highlitedItemIndex = max(0, maxFiltered.count - 1)
            delegate?.viewModelUpdated(self)
        }
    }

    public private(set) var highlitedItemIndex: Int = 0

    public init(with vehicle: VehicleProfileType) {
        self.currentFilteringVehicle = vehicle
    }

    public func reloadData() {
        loading = true
        repository.loadProgressData(for: currentFilteringVehicle.publicId) { [weak self] result in
            self?.loading = false
            switch result {
            case let .success(overviewData):
                self?.data = overviewData
            default:
                break
            }
        }
    }
}
