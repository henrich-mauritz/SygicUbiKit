import Swinject
import UIKit

// MARK: - TriplogOverviewView

public class TriplogOverviewView: UIView, TriplogOverviewViewProtocol, InjectableType {
    public var viewModel: TriplogOverviewViewModelProtocol? {
        didSet {
            //In case there is no intenet priority is to the no internet
            checkNoInternetState()
            guard let viewModel = viewModel else { return }
            let haveData = viewModel.cardViewModels.count > 0
            if viewModel.currentFilteringVehicle != nil {
                if viewModel.hasMoreThanOneVehicle {
                    emptyStateView.viewModel = TriplogEmptyStateViewModel(image: emptyStateView.viewModel?.image ?? UIImage(),
                                                                          title: "triplog.overview.emptyStateMultipleVehicle.title".localized,
                                                                          subtitle: "triplog.overview.emptyStateMultipleVehicle.subtitle".localized)
                } else {
                    emptyStateView.viewModel = TriplogEmptyStateViewModel(image: emptyStateView.viewModel?.image ?? UIImage(),
                                                                          title: "triplog.overview.emptyStateVehicle.title".localized,
                                                                          subtitle: "triplog.overview.emptyStateVehicle.subtitle".localized)
                }
            }
            emptyStateView.isHidden = haveData
            if haveData {
                layoutHeaderView()
            } else {
                tableView.tableHeaderView = nil
            }
            update(with: viewModel)
        }
    }

    public weak var monthsDelegate: TriplogMonthCardViewDelegate?

    private let headerView = TriplogScoreHeaderView()
    private static let monthsMargin: CGFloat = 24
    private let margin: CGFloat = 16

    private let emptyStateView: TriplogEmptyState = {
        let emptyView = TriplogEmptyState(frame: .zero)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.isHidden = true
        //default state
        let image = UIImage(named: "emptyTripLog", in: .module, compatibleWith: nil)
        emptyView.viewModel = TriplogEmptyStateViewModel(image: image, title: "triplog.overview.emptyTitle".localized, subtitle: "triplog.overview.emptySubtitle".localized)
        return emptyView
    }()

    private lazy var tableView: UITableView = {
        let tableV = UITableView(frame: .zero, style: .plain)
        tableV.delegate = self
        tableV.dataSource = self
        tableV.estimatedRowHeight = 308
        tableV.rowHeight = UITableView.automaticDimension
        tableV.register(TriplogOverviewTableViewMonthsCell.self, forCellReuseIdentifier: TriplogOverviewTableViewMonthsCell.identifier)
        tableV.register(DisclosureTableViewCell.self, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
        tableV.separatorStyle = .none
        tableV.backgroundColor = .clear
        return tableV
    }()

    private let refresher = UIRefreshControl()

    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .foregroundPrimary
        return indicator
    }()

    private let monthScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.clipsToBounds = false
        return scrollView
    }()

    private var items: [TriplogOverviewCardViewModelProtocol] = []

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundPrimary
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func reloadTripsData(fromFail: Bool = false) {
        guard let _ = self.viewModel?.cardViewModels, fromFail == false else {
            emptyStateView.isHidden = true
            tableView.tableHeaderView = nil
            tableView.reloadData()
            return
        }
        reloadData()
    }

    @objc
private func performPullToRefresh() {
        reloadData(showActivityIndicator: false)
    }

    @objc
private func reloadData(showActivityIndicator: Bool = true) {
        guard let viewModel = self.viewModel else {
            self.tableView.refreshControl?.endRefreshing()
            return
        }
        if showActivityIndicator {
            activityIndicator.startAnimating()
        }
        viewModel.reloadData(clearCache: true) {[weak self] finished in
            self?.activityIndicator.stopAnimating()
            if !finished {
                self?.checkNoInternetState()
            }
        }
    }

    private func update(with viewModel: TriplogOverviewViewModelProtocol) {
        headerView.leftTitleLabel?.text = viewModel.drivingScoreText
        headerView.leftDescriptionLabel.text = viewModel.drivingScoreDescription
        headerView.rightTitleLabel?.text = viewModel.kilometersDrivenText
        headerView.rightDescriptionLabel.text = viewModel.kilometersDrivenDescription
        headerView.configure(with: viewModel.visualsConfig)
        items = viewModel.cardViewModels
        tableView.reloadData()
        refresher.endRefreshing()
    }

    private func setupLayout() {
        monthScrollView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        layoutHeaderView()
        addSubview(tableView)
        addSubview(activityIndicator)
        cover(with: emptyStateView)

        var constraints = [NSLayoutConstraint]()

        constraints.append(tableView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(tableView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: bottomAnchor))

        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))

        NSLayoutConstraint.activate(constraints)
        tableView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(performPullToRefresh), for: .valueChanged)
    }

    /// This functino will just check the special case wehre there is no internet and the viewModel previwously had no data
    /// in this case no internet gets priprity
    private func checkNoInternetState() {
        if ReachabilityManager.shared.status == .unreachable {
            emptyStateView.isHidden = true
        }
        tableView.refreshControl?.endRefreshing()
    }

    private func layoutHeaderView() {
        //Setting the header
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        tableView.tableHeaderView = headerView
        headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = tableView.tableHeaderView //hack here but is force to recalculate layout
        tableView.layoutIfNeeded()
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension TriplogOverviewView: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let monthCardsCount = viewModel?.cardViewModels.count else { return 0 }
        return monthCardsCount > 0 ? 1 : 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TriplogOverviewTableViewMonthsCell.identifier) as? TriplogOverviewTableViewMonthsCell else {
                fatalError("No TriplogOverviewMonthsCell cell registered yet")
            }
            cell.configureWith(items: items)
            cell.delegate = self
            return cell
        } else {
            guard let disclosureCell = container.resolve(TripDetailScoreCellProtocol.self) else {
                return UITableViewCell()
            }

            disclosureCell.configure(with: "triplog.overview.monthlyStats".localized,
                                     icon: UIImage(named: "triglavIconsTriglavStats", in: .module, compatibleWith: nil),
                                     margins: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16))
            return disclosureCell
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        monthsDelegate?.presentMonthlyStatsTapped()
    }
}

// MARK: TriplogOverviewTableViewMonthsCellDelgate

extension TriplogOverviewView: TriplogOverviewTableViewMonthsCellDelgate {
    func tripOverviewCellDidSelect(item: TriplogOverviewCardViewModelProtocol) {
        monthsDelegate?.triplogMonthCardDidSelect(item)
    }
}
