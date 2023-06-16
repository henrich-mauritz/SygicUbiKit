import Foundation
import UIKit

// MARK: - MonthlyStatsMonthSelectorViewControllerDelegate

protocol MonthlyStatsMonthSelectorViewControllerDelegate: AnyObject {
    func monthSelectorDidSelectMonth(with monthDate: Date, monthId: String)
}

// MARK: - MonthlyStatsMonthSelectorViewController

class MonthlyStatsMonthSelectorViewController: UITableViewController, InjectableType {
    weak var delegate: MonthlyStatsMonthSelectorViewControllerDelegate?
    var viewModel: MonthlyStatsMonthSelectorViewModel

    init(with filteringVehicle: VehicleProfileType?) {
        self.viewModel = MonthlyStatsMonthSelectorViewModel(with: filteringVehicle)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "monthlyStats.calendar.title".localized
        tableView.separatorStyle = .none
        tableView.backgroundColor = .backgroundPrimary
        tableView.register(MonthlyStatsMonthSelectorCell.self, forCellReuseIdentifier: MonthlyStatsMonthSelectorCell.identifier)
        viewModel.delegate = self
        loadData()
        if let currentFilteringVehicle = viewModel.currentFilteringVehicle, viewModel.hasMoreThanOneVehicle {
            let indicatorView = VPVehicleIndicatorView(frame: .zero)
            indicatorView.update(with: currentFilteringVehicle.name.uppercased())
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicatorView)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    public func loadData() {
        viewModel.loadData(clearCache: true)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let analiticRegistering = container.resolve(AnalyticsRegistering.self) else { return }
        analiticRegistering.registerAnalytic(with: AnalyticsKeys.didShowMonthlyStatMonthSelector, parameters: nil)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MonthlyStatsMonthSelectorCell.identifier, for: indexPath) as? MonthlyStatsMonthSelectorCell,
              let items = viewModel.items else {
            return UITableViewCell()
        }
        cell.update(with: items[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let items = viewModel.items else { return }
        let item = items[indexPath.row]
        delegate?.monthSelectorDidSelectMonth(with: item.monthItem.date, monthId: item.monthItem.id)
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let items = viewModel.items, items[indexPath.row].score != nil else { return false }
        return true
    }
}

// MARK: MonthlyStatsMonthSelectorViewModelDelegate

extension MonthlyStatsMonthSelectorViewController: MonthlyStatsMonthSelectorViewModelDelegate {
    func viewModelDidUpdate(viewModel: MonthlyStatsMonthSelectorViewModel) {
        tableView.reloadData()
        dismissErrorView()
        if viewModel.numberOfItems == 0 {
            var subtitle = "monthlyStats.calendar.emptySubtitle".localized
            if viewModel.hasMoreThanOneVehicle {
                subtitle = "monthlyStats.calendar.emptySubtitleMultipleVehicle".localized
            }
            tableView.backgroundView = EmptyMonthStatsView(with: EmptyMonthlyStatViewModel(title: "monthlyStats.calendar.emptyTitle".localized,
                                                                                           subtitle: subtitle,
                                                                                           image: UIImage(named: "emtpyMonthList", in: .module, compatibleWith: nil)))
        }
    }

    func viewModelDidFail(viewModel: MonthlyStatsMonthSelectorViewModel, error: Error) {
//        guard let error = error as? NetworkError else {
//            return
//        }
        let error = NetworkError.error(from: error as NSError)
        let style: MessageViewModel.MessageViewModelStyle = error == .noInternetConnection ? .noInternet : .error
        let messageViewModel = MessageViewModel.viewModel(with: style)
        presentErrorView(with: messageViewModel)
    }
}
