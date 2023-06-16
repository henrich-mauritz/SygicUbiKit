import Swinject
import UIKit

// MARK: - RewardsListViewDelegate

public protocol RewardsListViewDelegate: AnyObject {
    func rewardsListView(_ view: RewardsListViewProtocol, didSelect reward: RewardViewModelProtocol)
}

// MARK: - RewardsListViewProtocol

public protocol RewardsListViewProtocol where Self: UIView {
    var delegate: RewardsListViewDelegate? { get set }
    var errorViewContainer: UIView { get }
    func update(with viewModel: RewardsListViewModelProtocol?)
    func toggleSegmentControllRedDotAt(_ index: Int, value: Bool)
    func selectSegment(at index: Int)
}

// MARK: - RewardsTableView

public class RewardsTableView: UIView, RewardsListViewProtocol, InjectableType {
    public weak var delegate: RewardsListViewDelegate?

    private var viewModel: RewardsListViewModelProtocol? {
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
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: headerHeight))
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(performPullToRefresh), for: .valueChanged)
        table.refreshControl = refresher
        return table
    }()

    lazy private var segmentedControl: SygicSegmentedControl = {
        let segmentControl = SygicSegmentedControl(items: [
            RewardsFilter.filter(for: 0).localizedString,
            RewardsFilter.filter(for: 1).localizedString,
        ])
        segmentControl.isHidden = true
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.widthAnchor.constraint(equalToConstant: 250).isActive = true
        segmentControl.addTarget(self, action: #selector(segmentControlChanged(_:)), for: .valueChanged)
        return segmentControl
    }()

    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .foregroundPrimary
        indicator.startAnimating()
        return indicator
    }()

    private let headerHeight: CGFloat = 80

    private lazy var noRewardsView: RewardsEmptyView = {
        let view = RewardsEmptyView()
        return view
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func update(with viewModel: RewardsListViewModelProtocol?) {
        if viewModel === self.viewModel {
            updateView()
            return
        }
        self.viewModel = viewModel
    }

    private func updateView() {
        guard let viewModel = self.viewModel else { return }
        if viewModel.loadingData {
            if tableView.refreshControl?.isRefreshing == false {
                activityIndicator.startAnimating()
            }
        } else {
            activityIndicator.stopAnimating()
            tableView.refreshControl?.endRefreshing()
        }

        if viewModel.rewardsAvailable {
            segmentedControl.isHidden = false
            segmentedControl.showNotificationBadge(at: 1, show: viewModel.hasNewGainedReward)
            if viewModel.rewards.count == 0 && viewModel.loadingData == false {
                if segmentedControl.selectedSegmentIndex == 0 {
                    noRewardsView.titleLabel.text = "rewards.emptyAvailableTitle".localized
                } else {
                    noRewardsView.titleLabel.text = "rewards.emptyGainedTitle".localized
                }
                tableView.backgroundView = noRewardsView
            } else {
                tableView.backgroundView = nil
            }
        } else {
            segmentedControl.isHidden = true
            tableView.backgroundView = nil
        }
        tableView.reloadData()
    }

    @objc func performPullToRefresh() {
        guard let viewModel = self.viewModel else {
            tableView.refreshControl?.endRefreshing()
            return
        }
        viewModel.reloadData(cleanCache: true)
    }

    private func setupLayout() {
        guard let header = tableView.tableHeaderView else { return }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        header.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        addSubview(activityIndicator)
        header.addSubview(segmentedControl)
        var constraints = [NSLayoutConstraint]()
        constraints.append(tableView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(tableView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(header.heightAnchor.constraint(equalToConstant: headerHeight))
        constraints.append(header.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 1))
        constraints.append(segmentedControl.centerXAnchor.constraint(equalTo: header.centerXAnchor))
        constraints.append(segmentedControl.centerYAnchor.constraint(equalTo: header.centerYAnchor, constant: 0))
        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    @objc private func segmentControlChanged(_ sender: Any) {
        viewModel?.rewardsFilter = RewardsFilter.filter(for: segmentedControl.selectedSegmentIndex)
        if segmentedControl.selectedSegmentIndex == 1 {
            AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticKeys.rewardGainedShown, parameters: nil)
            UserDefaults.standard.setValue(nil, forKey: RewardsModule.UserDefaultKeys.awardedRewardKey)
        } else {
            AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticKeys.rewardShown, parameters: nil)
        }
    }

    public func toggleSegmentControllRedDotAt(_ index: Int, value: Bool) {
        segmentedControl.showNotificationBadge(at: index, show: value)
    }

    public func selectSegment(at index: Int) {
        segmentedControl.selectSegment(at: index, animated: false)
    }
}

// MARK: UITableViewDataSource

extension RewardsTableView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let rewards = self.viewModel?.rewards, rewards.count > 0 else {
            return 0
        }
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.rewards.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel, let item = container.resolve(RewardCellProtocol.self) else { return UITableViewCell() }
        item.update(with: viewModel.rewards[indexPath.row])
        guard let cell = item as? UITableViewCell else { return UITableViewCell() }
        return cell
    }
}

// MARK: UITableViewDelegate

extension RewardsTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let reward = viewModel?.rewards[indexPath.row] else { return }
        delegate?.rewardsListView(self, didSelect: reward)
    }
}
