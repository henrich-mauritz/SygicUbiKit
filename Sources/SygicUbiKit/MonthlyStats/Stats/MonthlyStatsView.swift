import UIKit

// MARK: - MonthlyStatsSection

enum MonthlyStatsSection: Int {
    case overallScore
    case eventsScore
    case otherStats
    case graphs
    case rewards
    case badges
    static var count: Int { 6 }
    var sectionTitle: String? {
        switch self {
        case .rewards:
            return "monthlyStats.overview.rewardsTitle".localized
        case .badges:
            return "monthlyStats.overview.badgesTitle".localized
        default:
            return nil
        }
    }
}

// MARK: - MonthlyStatsViewDelegate

public protocol MonthlyStatsViewDelegate: AnyObject {
    func shouldOpenSafariController(with url: URL)
    func monthlyStatsViewDidScroll(with scrollView: UIScrollView)
}

// MARK: - MonthlyStatsView

class MonthlyStatsView: UIView, MonthlyStatsViewType, InjectableType {
    var viewModel: MonthlyStatsViewModelType? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            if viewModel.stats != nil {
                toggleEmptyState(value: !viewModel.hasStatsToShow)
            } else {
                toggleEmptyState(value: false)
            }
            loadingIndicator.stopAnimating()
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }

    var errorView: UIView {
        tableView
    }

    weak var delegate: MonthlyStatsViewDelegate?

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(performPullToRefresh), for: .valueChanged)
        table.refreshControl = refresher
        table.register(MonthlyStatsOverviewCell.self, forCellReuseIdentifier: MonthlyStatsOverviewCell.identifier)
        table.register(MonthlyStatsEventScoreCell.self, forCellReuseIdentifier: MonthlyStatsEventScoreCell.identifier)
        table.register(MonthlyStatsOtherStatsCell.self, forCellReuseIdentifier: MonthlyStatsOtherStatsCell.identifier)
        table.register(MonthlyStatsGraphTableViewCell.self, forCellReuseIdentifier: MonthlyStatsGraphTableViewCell.identifier)
        table.register(RewardCell.self, forCellReuseIdentifier: RewardCell.identifier)
        table.register(MonthlyStatsBadgesCell.self, forCellReuseIdentifier: MonthlyStatsBadgesCell.identifier)
        return table
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .foregroundPrimary
        return indicator
    }()

    private lazy var emptyView: EmptyMonthStatsView = {
        let view = EmptyMonthStatsView()
        view.isHidden = true
        return view
    }()

    private var distanceInitialLayout: Bool = false
    private var scoreInitialLayout: Bool = false

    //MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func toggleLoadingIndicator(value: Bool) {
        if value {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }

    func toggleEmptyState(value: Bool) {
        tableView.isHidden = value
        emptyView.isHidden = !value
    }

    public func stopRefreshing(fromError: Bool) {
        tableView.refreshControl?.endRefreshing()
        loadingIndicator.stopAnimating()
        toggleEmptyState(value: !fromError)
    }

    private func setupLayout() {
        backgroundColor = .backgroundPrimary
        cover(with: tableView, toSafeArea: false)
        cover(with: emptyView)
        addSubview(loadingIndicator)
        var constrains: [NSLayoutConstraint] = []
        constrains.append(loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        constrains.append(loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))
        NSLayoutConstraint.activate(constrains)
    }

    @objc
private func performPullToRefresh() {
        viewModel?.loadData(clearCache: true)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension MonthlyStatsView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = self.viewModel?.stats else { return 0 }
        return MonthlyStatsSection.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = MonthlyStatsSection(rawValue: section), let title = section.sectionTitle, let stats = viewModel?.stats else { return UIView() }
        if section == .badges {
            if stats.achievedBadges.count == 0 {
                return UIView()
            }
        } else if section == .rewards {
            if stats.awardedContests.count == 0 {
                return UIView()
            }
        }

        let header = MonthlyStatsSectionHeaderView()
        header.titleLabel.text = title
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = MonthlyStatsSection(rawValue: section),
              let _ = section.sectionTitle,
              let stats = viewModel?.stats else { return 10 }

        if section == .badges {
            if stats.achievedBadges.count == 0 {
                return 10
            }
        } else if section == .rewards {
            if stats.awardedContests.count == 0 {
                return 10
            }
        }
        return 45
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = MonthlyStatsSection(rawValue: section), let stats = viewModel?.stats else { return 0 }
        switch section {
        case .graphs:
            return 2
        case .rewards:
            return stats.awardedContests.count
        case .badges:
            return stats.achievedBadges.count > 0 ? 1 : 0
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel else { return UITableViewCell() }
        guard let section = MonthlyStatsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        var cell: UITableViewCell?
        switch section {
        case .overallScore:
            let scoreCell = tableView.dequeueReusableCell(withIdentifier: MonthlyStatsOverviewCell.identifier, for: indexPath) as? MonthlyStatsOverviewCell
            scoreCell?.update(with: viewModel.overallCellViewModel)
            cell = scoreCell
        case .eventsScore:
            let eventCell = tableView.dequeueReusableCell(withIdentifier: MonthlyStatsEventScoreCell.identifier, for: indexPath) as? MonthlyStatsEventScoreCell
            if let eventsCellViewModel = viewModel.eventsCellViewModel {
                eventCell?.update(with: eventsCellViewModel)
            }
            eventCell?.delegate = self
            cell = eventCell
        case .otherStats:
            let otherCell = tableView.dequeueReusableCell(withIdentifier: MonthlyStatsOtherStatsCell.identifier, for: indexPath) as? MonthlyStatsOtherStatsCell
            if let otherStats = viewModel.otherStatsCellViewModel {
                otherCell?.update(with: otherStats)
            }
            cell = otherCell
        case .rewards:
            let rewardCell = tableView.dequeueReusableCell(withIdentifier: RewardCell.identifier, for: indexPath) as? RewardCell
            if let contestItemData = viewModel.rewardsCellViewModel(at: indexPath.row) {
                rewardCell?.update(with: contestItemData)
            }
            cell = rewardCell
        case .badges:
            let badgeCell = tableView.dequeueReusableCell(withIdentifier: MonthlyStatsBadgesCell.identifier, for: indexPath) as? MonthlyStatsBadgesCell
            if let badgesItems = viewModel.badgesCellViewModel {
                badgeCell?.update(with: badgesItems)
            }
            cell = badgeCell

        case .graphs:
            let graphCell = tableView.dequeueReusableCell(withIdentifier: MonthlyStatsGraphTableViewCell.identifier, for: indexPath) as? MonthlyStatsGraphTableViewCell
            if indexPath.row == 0 {
                if let distanceDataViewModel = viewModel.distanceGraphCellViewModel {
                    graphCell?.configureGraph(with: distanceDataViewModel, resetValues: !distanceInitialLayout)
                }
            } else {
                if let scoreDataViewModel = viewModel.scoreGrpahCellViewModel {
                    graphCell?.configureGraph(with: scoreDataViewModel, resetValues: !scoreInitialLayout)
                }
            }
            cell = graphCell
        }
        cell?.backgroundColor = .clear
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.monthlyStatsViewDidScroll(with: scrollView)
    }
}

// MARK: MonthlyStatsEventScoreCellDelegate

extension MonthlyStatsView: MonthlyStatsEventScoreCellDelegate {
    func shouldOpenSafariController(with url: URL) {
        delegate?.shouldOpenSafariController(with: url)
    }
}
