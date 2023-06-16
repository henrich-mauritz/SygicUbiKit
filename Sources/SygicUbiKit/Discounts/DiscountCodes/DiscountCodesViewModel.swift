import Foundation
import UIKit

// MARK: - DiscountCodesFilter

public enum DiscountCodesFilter {
    case available
    case archive

    public var localizedString: String {
        switch self {
        case .available:
            return "discounts.yourCodes.available".localized.uppercased()
        case .archive:
            return "discounts.yourCodes.archive".localized.uppercased()
        }
    }

    static func filter(for index: Int) -> DiscountCodesFilter {
        switch index {
        case 1:
            return .archive
        default:
            return .available
        }
    }
}

// MARK: - DiscountCodesViewModel

public class DiscountCodesViewModel: DiscountCodesViewModelProtocol, InjectableType {
    public var segementedControlTitles: (value1: String, value2: String) {
        let val1 = DiscountCodesFilter.filter(for: 0).localizedString
        let val2 = DiscountCodesFilter.filter(for: 1).localizedString
        return (val1, val2)
    }

    public weak var delegate: DiscountsViewModelDelegate?

    public private(set) var loading: Bool = false

    open var items: [DiscountCode] {
        filter == .available ? availableCodes : archivedCodes
    }

    private var filter: DiscountCodesFilter = .available
    private var availableCodes: [DiscountCode] = []
    private var archivedCodes: [DiscountCode] = []
    private var dataItems: [DiscountCode] = [DiscountCode]()
    private var data: DiscountCodesDataProtocol?

    public var currentSelectedIndex: Int {
        let index: Int = filter == .available ? 0 : 1
        return index
    }

    public var discountCodesViewNumberOfSections: Int { currentSelectedIndex == 0 ? 2 : 1 }
    private lazy var repository: DiscountCodesRepositoryType = container.resolveDiscountCodeRepo()
    private lazy var vehicleRepository = container.resolveVehicleProfileRepo()

    public var hasMoreThanOneVehicle: Bool {
        vehicleRepository.activeVehicles.count > 1
    }

    public var currentFilteringVehicle: VehicleProfileType?

    init(with vehicle: VehicleProfileType) {
        self.currentFilteringVehicle = vehicle
    }

    public func reloadData(completion: @escaping (() -> Void)) {
        guard let vehicleId = currentFilteringVehicle?.publicId else {
            completion()
            return
        }
        loading = true
        repository.loadDiscountCodeData(for: vehicleId) { [weak self] result in
            guard let self = self else { return }
            self.loading = false
            switch result {
            case let .success(discountData):
                self.data = discountData
                self.dataItems.removeAll()
                self.updateDiscounts(data: discountData)
                self.delegate?.viewModelUpdated(self)
            case let .failure(error):
                self.delegate?.viewModelDidFail(with: error)
            }
            completion()
        }
    }

    private func updateDiscounts(data: DiscountCodesDataProtocol) {
        dataItems.append(contentsOf: data.items)
        availableCodes = dataItems.filter { $0.state == .available && $0.usedAt == nil }.sorted(by: { $0.validUntil.compare($1.validUntil) == .orderedAscending })
        archivedCodes = dataItems.filter { $0.state != .available || $0.usedAt != nil }.sorted(by: { code1, code2 -> Bool in
            let date1 = code1.usedAt ?? code1.validUntil
            let date2 = code2.usedAt ?? code2.validUntil
            return date1.compare(date2) == .orderedDescending
        })
    }

    public func loadMoreData() {
        let nextPage = currentPage() + 1
        guard nextPage <= pagesCount(),
              let vehicleId = currentFilteringVehicle?.publicId else {
            return
        }
        repository.loadMoreDiscountCodeData(for: nextPage, with: vehicleId) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(discountData):
                self.data = discountData
                self.updateDiscounts(data: discountData)
                self.delegate?.viewModelUpdated(self)
            default:
                break
            }
        }
    }

    public func updateFilter(with index: Int) {
        filter = DiscountCodesFilter.filter(for: index)
    }

    private func currentPage() -> Int {
        return data?.page ?? 0
    }

    private func pagesCount() -> Int {
        return data?.pagesCount ?? 0
    }

    public func configure(cell: UITableViewCell, with discountCode: DiscountCodeView, insuranceCode: DiscountCodeView) {
        insuranceCode.contentStackView.removeFromSuperview()
        let containerView = UIView(frame: .zero)
        let whiteBGView = UIView(frame: .zero)
        whiteBGView.translatesAutoresizingMaskIntoConstraints = false
        whiteBGView.layer.cornerRadius = Styling.cornerRadius
        whiteBGView.cover(with: insuranceCode.contentStackView, insets: NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16))
        whiteBGView.backgroundColor = .backgroundPrimary
        containerView.addSubview(whiteBGView)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(whiteBGView.topAnchor.constraint(equalTo: containerView.topAnchor))
        constraints.append(whiteBGView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor))
        constraints.append(whiteBGView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16))
        constraints.append(whiteBGView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16))
        NSLayoutConstraint.activate(constraints)
        containerView.layer.cornerRadius = Styling.cornerRadius
        discountCode.contentStackView.addArrangedSubview(containerView)
        cell.contentView.cover(with: discountCode, insets: .zero)
    }

    public func discountViewWillPresentInsurance(cell: UITableViewCell, with discountCode: DiscountCodeView, insuranceCode: DiscountCodeView, with item: DiscountCode) {
        insuranceCode.contentStackView.removeFromSuperview()
        let containerView = UIView(frame: .zero)
        let whiteBGView = UIView(frame: .zero)
        whiteBGView.translatesAutoresizingMaskIntoConstraints = false
        whiteBGView.layer.cornerRadius = Styling.cornerRadius
        whiteBGView.cover(with: insuranceCode.contentStackView, insets: NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16))
        whiteBGView.backgroundColor = .backgroundPrimary
        containerView.addSubview(whiteBGView)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(whiteBGView.topAnchor.constraint(equalTo: containerView.topAnchor))
        constraints.append(whiteBGView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor))
        constraints.append(whiteBGView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16))
        constraints.append(whiteBGView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16))
        NSLayoutConstraint.activate(constraints)
        containerView.layer.cornerRadius = Styling.cornerRadius
        discountCode.contentStackView.addArrangedSubview(containerView)
        cell.contentView.cover(with: discountCode, insets: .zero)
    }

    //MARK: - Analytics

    public func registerCodesShown() {
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.discountCodeShown, parameters: nil)
    }
}

extension DiscountCode {
    func formatDiscount(discount: Double) -> String {
        let stringFormatter = "discounts.codeBubble.descriptionPrefix".localized
        return String(format: stringFormatter, discount)
    }
}

extension Date {
    func formatValidityDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        var description: String
        if compare(Date()) == .orderedAscending {
            description = "discounts.codeBubble.expiredTitle".localized
        } else {
            description = "discounts.codeBubble.validUntilTitle".localized
        }
        return description + " " + formatter.string(from: self)
    }

    func formatUsedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "discounts.codeBubble.usedTitle".localized + " " + formatter.string(from: self)
    }
}
