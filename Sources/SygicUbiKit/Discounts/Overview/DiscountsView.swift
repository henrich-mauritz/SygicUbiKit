import Swinject
import UIKit

// MARK: - DiscountsViewDelegate

public protocol DiscountsViewDelegate: AnyObject {
    func discountsViewWantsShowInfo(_ view: DiscountsViewProtocol)
    func discountsViewWantsShowProgress(_ view: DiscountsViewProtocol)
    func discountsViewWantsShowCodes(_ view: DiscountsViewProtocol)
    func discountsView(_ view: DiscountsViewProtocol, wantsClaimDiscount completion: @escaping ((_ finished: Bool) -> ()))
    func presentDiscountWebView(at url: URL)
}

// MARK: - DiscountsViewProtocol

public protocol DiscountsViewProtocol where Self: UIView {
    var delegate: DiscountsViewDelegate? { get set }
    var errorViewContainer: UIView { get }
    func update(with viewModel: DiscountsViewModelType?)
    func toggleActivityIndicator(value: Bool)
}

// MARK: - DiscountsView

public class DiscountsView: UIView, DiscountsViewProtocol, InjectableType {
    public weak var delegate: DiscountsViewDelegate?

    public var container: Container?

    private var viewModel: DiscountsViewModelType? {
        didSet {
            updateView()
        }
    }

    public var errorViewContainer: UIView {
        return tableView
    }

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.tableHeaderView = UIView()
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(performPullToRefresh), for: .valueChanged)
        table.refreshControl = refresher
        table.register(DiscountDetailCell.self, forCellReuseIdentifier: DiscountDetailCell.cellReuseIdentifier)
        return table
    }()

    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .foregroundPrimary
        return indicator
    }()

    private let margin: CGFloat = 16

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func updateView() {
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
        toggleActivityIndicator(value: false)
    }

    public func update(with viewModel: DiscountsViewModelType?) {
        self.viewModel = viewModel
    }

    @objc
func performPullToRefresh() {
        reloadData(showActivityIndicator: false)
    }

    @objc
private func reloadData(showActivityIndicator: Bool = true) {
        guard let viewModel = self.viewModel else {
            tableView.refreshControl?.endRefreshing()
            return
        }
        if showActivityIndicator {
            activityIndicator.startAnimating()
        }
        viewModel.reloadData(completion: {[weak self] _ in
            self?.activityIndicator.stopAnimating()
        })
    }

    private func setupLayout() {
        backgroundColor = .backgroundPrimary
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        addSubview(activityIndicator)
        var constraints = [NSLayoutConstraint]()
        constraints.append(tableView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(tableView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    private func setupClaimedDicountView() -> UIView {
        let discountView = DiscountCodeView()
        if let claimedDiscount = viewModel?.claimedDiscount {
            discountView.titleLabel.text = claimedDiscount.claimedTitle
            discountView.codeLabel.text = claimedDiscount.claimedCode
            discountView.validityLabel.text = claimedDiscount.claimedValidity
            if let config = container.resolve(DiscountConfigurable.self),
               claimedDiscount.isValid == true {
                discountView.showApplyButton {[weak self] _ in
                    self?.activityIndicator.startAnimating()
                    self?.tableView.isUserInteractionEnabled = false
                    config.fetchInsuranceURL(fromCode: claimedDiscount.claimedCode) {[weak self] url in
                        self?.activityIndicator.stopAnimating()
                        self?.tableView.isUserInteractionEnabled = true
                        guard let url = url else {
                            return
                        }
                        self?.delegate?.presentDiscountWebView(at: url)
                    }
                }
                discountView.applyButton.titleLabel.text = "discounts.codeBubble.applyButton".localized.uppercased()
            }
        }
        return discountView
    }

    private func setupClaimDicountView() -> UIView {
        let discountView = DiscountClaimView()
        discountView.discountLabel.text = viewModel?.claimableDiscount?.amount
        discountView.button.isEnabled = viewModel?.claimableDiscount?.canBeClaimed ?? false
        discountView.button.addTarget(self, action: #selector(claimDiscount(_:)), for: .touchUpInside)
        if let vehicleName = viewModel?.currentFilteringVehicle?.name {
            discountView.configureWithvehicle(with: vehicleName)
        }
        return discountView
    }

    @objc
private func claimDiscount(_ sender: UIControl) {
        sender.isEnabled = false
        delegate?.discountsView(self, wantsClaimDiscount: { finished in
            sender.isEnabled = !finished
        })
    }

    public func toggleActivityIndicator(value: Bool) {
        guard let refreshControl = self.tableView.refreshControl, refreshControl.isRefreshing == false else {
            return
        }
        tableView.isHidden = value
        if value {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

// MARK: UITableViewDataSource

extension DiscountsView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = self.viewModel else {
            return 0
        }

        return 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            switch viewModel?.state {
            case .initial,
                 .progress:
                return 2
            case .claimed:
                return 1
            default:
                break
            }
        } else if section == 1 {
            return viewModel?.infoDetails.count ?? 0
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        if indexPath.section == 0 {
            if viewModel.state == .claimed {
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                let discountView = setupClaimedDicountView()
                cell.contentView.cover(with: discountView, insets: NSDirectionalEdgeInsets(top: 10, leading: margin, bottom: 10, trailing: margin))
                return cell
            } else {
                if indexPath.row == 0 {
                    let cell = UITableViewCell()
                    cell.backgroundColor = .clear
                    let challengeView = DiscountsChallengesView()
                    challengeView.viewModel = viewModel.challengeViewModel
                    cell.contentView.cover(with: challengeView, insets: NSDirectionalEdgeInsets(top: 10, leading: margin, bottom: 10, trailing: margin))
                    return cell
                } else {
                    let cell = UITableViewCell()
                    cell.backgroundColor = .clear
                    let discountView = setupClaimDicountView()
                    cell.contentView.cover(with: discountView, insets: NSDirectionalEdgeInsets(top: 10, leading: margin, bottom: 10, trailing: margin))
                    return cell
                }
            }
        } else if indexPath.section == 1 {
            let item = viewModel.infoDetails[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: DiscountDetailCell.cellReuseIdentifier, for: indexPath) as! DiscountDetailCell
            cell.icon.image = item.icon
            cell.titleLabel.text = item.title
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate

extension DiscountsView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 1
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1 else { return }
        switch indexPath.row {
        case 0:
            delegate?.discountsViewWantsShowCodes(self)
        case 1:
            delegate?.discountsViewWantsShowProgress(self)
        case 2:
            delegate?.discountsViewWantsShowInfo(self)
        default:
            break
        }
    }
}
