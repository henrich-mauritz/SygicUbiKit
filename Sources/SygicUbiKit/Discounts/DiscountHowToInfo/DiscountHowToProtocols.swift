import UIKit

// MARK: - DiscountHowToModelProtocol

public protocol DiscountHowToModelProtocol {
    func loadHowToData(_ completion: @escaping (Result<DiscountHowToDataProtocol, Error>) -> ())
}

// MARK: - DiscountHowToDataProtocol

public protocol DiscountHowToDataProtocol {
    var title: String { get }
    var items: [DiscountTerms] { get }
}

// MARK: - DiscountTerms

public protocol DiscountTerms {
    var title: String { get }
    var description: String { get }
}

// MARK: - DiscountHowToViewProtocol

public protocol DiscountHowToViewProtocol where Self: UIView {
    var viewModel: DiscountHowToViewModelProtocol? { get set }
}

// MARK: - DiscountHowToViewModelProtocol

public protocol DiscountHowToViewModelProtocol {
    var title: String { get }
    var items: [DiscountTerms] { get }
    var loading: Bool { get }
    var delegate: DiscountsViewModelDelegate? { get set }
    var hasMoreThanOneVehicle: Bool { get }
    var currentFilteringVehicle: VehicleProfileType { get set }
    func reloadData()
}
