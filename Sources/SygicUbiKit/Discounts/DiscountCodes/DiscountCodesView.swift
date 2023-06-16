import Swinject
import UIKit

// MARK: - DiscountCodesViewDelegate

protocol DiscountCodesViewDelegate: AnyObject {
    func presentDiscountWebView(at url: URL)
}

// MARK: - DiscountCodesView

public class DiscountCodesView: UIView, DiscountCodesViewProtocol, InjectableType {
    weak var delegate: DiscountCodesViewDelegate?

    public var viewModel: DiscountCodesViewModelProtocol? {
        didSet {
            guard let viewModel = viewModel else { return }

            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
            if viewModel.loading && viewModel.items.count == 0 {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
            let titles = viewModel.segementedControlTitles
            segmentedControl.updateSegementedControl(with: [titles.value1, titles.value2])
            underheaderTextLabel.text = viewModel.subHeaderText
            setupBackgroundView()
        }
    }

    lazy private var segmentedControl: SygicSegmentedControl = {
        let segmentControl = SygicSegmentedControl(items: nil)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.widthAnchor.constraint(equalToConstant: 200).isActive = true
        segmentControl.addTarget(self, action: #selector(segmentControlChanged(_:)), for: .valueChanged)
        return segmentControl
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: headerHeight))
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.estimatedRowHeight = 191
        table.rowHeight = UITableView.automaticDimension
        table.register(DiscountCodesInfoTableViewCell.self, forCellReuseIdentifier: DiscountCodesInfoTableViewCell.cellReuseIdentifier)
        table.delegate = self
        table.dataSource = self
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        table.refreshControl = refresher
        return table
    }()

    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .foregroundPrimary
        indicator.startAnimating()
        return indicator
    }()

    private lazy var underheaderTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Styling.foregroundPrimary
        label.font = UIFont.stylingFont(UIFont.FontType.regular, with: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let formatter: DateFormatter = DateFormatter()

    private let headerHeight: CGFloat = 80

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupView() {
        backgroundColor = .backgroundPrimary
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        addSubview(activityIndicator)

        guard let header = tableView.tableHeaderView else { return }
        header.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(segmentedControl)
        header.addSubview(underheaderTextLabel)
        var constraints = [tableView.topAnchor.constraint(equalTo: topAnchor)]
        constraints.append(tableView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))
        //constraints.append(header.heightAnchor.constraint(equalToConstant: headerHeight))
        constraints.append(header.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 1))
        constraints.append(segmentedControl.centerXAnchor.constraint(equalTo: header.centerXAnchor))
        constraints.append(segmentedControl.topAnchor.constraint(equalTo: header.topAnchor, constant: 16))
        constraints.append(segmentedControl.bottomAnchor.constraint(equalTo: underheaderTextLabel.topAnchor, constant: -5))
        constraints.append(underheaderTextLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 53))
        constraints.append(underheaderTextLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -53))
        constraints.append(underheaderTextLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -16).withPriority(.defaultHigh-1))
        NSLayoutConstraint.activate(constraints)
    }

    @objc private func reloadData() {
        self.viewModel?.reloadData(completion: {})
    }

    @objc
private func segmentControlChanged(_ sender: SygicSegmentedControl) {
        viewModel?.updateFilter(with: sender.selectedSegmentIndex)
        underheaderTextLabel.text = viewModel?.subHeaderText
        setupBackgroundView()
        self.tableView.reloadData()
        DispatchQueue.main.async {
            self.tableView.layoutTableHeaderView()
        }
    }

    private func setupBackgroundView() {
        tableView.tableFooterView = viewModel?.footerView
        guard let viewModel = self.viewModel,
              let bgView = viewModel.discountCodesEmptyView(forStateAt: viewModel.currentSelectedIndex) else {
            return
        }
        if tableView.bounds == .zero {
            tableView.tableFooterView = viewModel.footerView
            return
        }
        bgView.frame = CGRect(x: 0, y: 0,
                              width: tableView.frame.width,
                              height: tableView.bounds.height - (tableView.tableHeaderView?.bounds.height ?? 0) - abs(tableView.bounds.origin.y) - layoutMargins.bottom)
        tableView.tableFooterView = bgView
    }

    public func prepareUIForGeneralError(value: Bool) {
        tableView.isHidden = value
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension DiscountCodesView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.discountCodesViewNumberOfSections
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel, !viewModel.loading else { return 0 }
        switch section {
        case 0:
            let itemsCount = viewModel.items.count
            if itemsCount == 0 && viewModel.discountCodesEmptyView(forStateAt: segmentedControl.selectedSegmentIndex) != nil {
                return 0
            } else {
                return itemsCount == 0 ? 1 : itemsCount
            }
        default:
            return 1
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            let items = viewModel.items
            if items.count == 0 {
                let emptyView = DiscountCodeView()
                let selectedIndex = viewModel.currentSelectedIndex
                emptyView.titleLabel.text = selectedIndex == 0 ? "discounts.codeBubble.empty".localized : "discounts.yourCodes.archiveEmpty".localized
                emptyView.contentStackView.removeArrangedSubview(emptyView.codeLabel)
                //TODO: Tu davame 10, ale este mame constrain v DiscountCodeView() ktory dal 36, ktory sa ma pouzit? 
                //emptyView.validityLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
                emptyView.adjustHeightOfValidityLabel(to: 10)
                emptyView.validityLabel.isHidden = true
                cell.contentView.cover(with: emptyView, insets: .zero)
            } else {
                let item = items[indexPath.row]
                let discountView = DiscountCodeView.view(for: item)

                if let insurance = item.insurancePolicy {
                    let insuranceView = DiscountCodeView()
                    insuranceView.backgroundColor = UIColor.backgroundTertiary.withAlphaComponent(0.07)
                    insuranceView.titleLabel.text = "discounts.codeBubble.insurancePolicyNumber".localized
                    insuranceView.codeLabel.font = UIFont.stylingFont(.thin, with: 30)
                    insuranceView.codeLabel.text = insurance
                    insuranceView.contentStackView.setCustomSpacing(0, after: insuranceView.codeLabel)
                    self.viewModel?.discountViewWillPresentInsurance(cell: cell, with: discountView, insuranceCode: insuranceView, with: item)
                } else {
                    if let config = container.resolve(DiscountConfigurable.self),
                       item.state == .available,
                       config.motorbikeSpecial,
                       let currentFilteringVehicle = viewModel.currentFilteringVehicle,
                       currentFilteringVehicle.vehicleType != .motorcycle {
                        discountView.showApplyButton {[weak self] code in
                            guard let code = code else {
                                return
                            }
                            self?.activityIndicator.startAnimating()
                            self?.tableView.isUserInteractionEnabled = false
                            config.fetchInsuranceURL(fromCode: code) {[weak self] url in
                                self?.activityIndicator.stopAnimating()
                                tableView.isUserInteractionEnabled = true
                                guard let url = url else {
                                    return
                                }
                                self?.delegate?.presentDiscountWebView(at: url)
                            }
                        }
                        discountView.applyButton.titleLabel.text = "discounts.codeBubble.applyButton".localized.uppercased()
                    }
                    if let config = container.resolve(DiscountConfigurable.self),
                       config.motorbikeSpecial,
                       let currentFilteringVehicle = viewModel.currentFilteringVehicle,
                       currentFilteringVehicle.vehicleType == .motorcycle {
                        discountView.applyButton.isHidden = true
                    }
                    cell.contentView.cover(with: discountView, insets: .zero)
                }
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: DiscountCodesInfoTableViewCell.cellReuseIdentifier) as? DiscountCodesInfoTableViewCell ?? DiscountCodesInfoTableViewCell()
            
            if let config = container.resolve(DiscountConfigurable.self),
               config.motorbikeSpecial,
               let currentFilteringVehicle = viewModel.currentFilteringVehicle,
               currentFilteringVehicle.vehicleType == .motorcycle {
                cell.setSpecialMotorbikeSubtitle()
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard viewModel?.items.count == indexPath.item + 1 else { return }
        viewModel?.loadMoreData()
    }
}

extension DiscountCodeView {
    static func view(for item: DiscountCode) -> DiscountCodeView {
        let discountView = DiscountCodeView()
        discountView.titleLabel.text = item.formatDiscount(discount: item.discountAmount)
        discountView.codeLabel.text = item.discountCode
        discountView.validityLabel.text = item.validityLocalizedDescription.uppercased()
        return discountView
    }
}
