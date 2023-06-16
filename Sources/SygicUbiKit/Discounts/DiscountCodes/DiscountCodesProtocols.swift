import Foundation
import UIKit

// MARK: - DiscountCodesModelProtocol

public protocol DiscountCodesModelProtocol {
    func loadDiscountCodeData(_ completion: @escaping (Result<DiscountCodesDataProtocol, Error>) -> ())
    func loadMoreDiscountCodeData(_ completion: @escaping (Result<DiscountCodesDataProtocol, Error>) -> ())
}

// MARK: - DiscountCodesDataProtocol

public protocol DiscountCodesDataProtocol {
    var page: Int { get }
    var pageSize: Int { get }
    var pagesCount: Int { get }
    var totalItemsCount: Int { get }
    var items: [DiscountCode] { get }
}

// MARK: - DiscountCode

public protocol DiscountCode {
    var discountCode: String { get }
    var discountAmount: Double { get }
    var validUntil: Date { get }
    var usedAt: Date? { get }
    var insurancePolicy: String? { get }
    var state: DiscountCodeState { get }
    var validityLocalizedDescription: String { get }
}

extension DiscountCode {
    var validityLocalizedDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        var description: String
        var date: Date?
        switch state {
        case .available:
            description = "discounts.codeBubble.validUntilTitle".localized
            date = validUntil
        case .expired:
            description = "discounts.codeBubble.expiredTitle".localized
            date = validUntil
        case .reversed:
            description = "discounts.codeBubble.notValidTitle".localized
        case .used:
            description = "discounts.codeBubble.usedTitle".localized
            date = usedAt
        }

        guard let usedDate = date else {
            return description
        }

        return description + " " + formatter.string(from: usedDate)
    }
}

// MARK: - DiscountCodesViewProtocol

public protocol DiscountCodesViewProtocol where Self: UIView {
    var viewModel: DiscountCodesViewModelProtocol? { get set }
    func prepareUIForGeneralError(value: Bool)
}

// MARK: - DiscountCodesViewModelProtocol

public protocol DiscountCodesViewModelProtocol: AnyObject {
    var items: [DiscountCode] { get }
    var segementedControlTitles: (value1: String, value2: String) { get }
    var loading: Bool { get }
    var delegate: DiscountsViewModelDelegate? { get set }
    var currentSelectedIndex: Int { get }
    var subHeaderText: String? { get }
    var footerView: UIView? { get }
    var discountCodesViewNumberOfSections: Int { get }
    var hasMoreThanOneVehicle: Bool { get }
    var currentFilteringVehicle: VehicleProfileType? { get set }
    func reloadData(completion: @escaping (() -> Void))
    func loadMoreData()
    func updateFilter(with index: Int)
    func discountViewWillPresentInsurance(cell: UITableViewCell, with discountCode: DiscountCodeView, insuranceCode: DiscountCodeView, with item: DiscountCode)
    func discountCodesEmptyView(forStateAt index: Int) -> UIView?
    func registerApplyOnlineAnalytics()
    func registerCodesShown()
}

public extension DiscountCodesViewModelProtocol {
    var subHeaderText: String? { nil }
    var footerView: UIView? { nil }
    func discountCodesEmptyView(forStateAt index: Int) -> UIView? { nil }
    func registerApplyOnlineAnalytics() {}
    func registerCodesShown() {}
}
