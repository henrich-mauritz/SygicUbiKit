import UIKit

// MARK: - DiscountProgressView

class DiscountProgressView: UIView, DiscountProgressViewProtocol {
    var viewModel: DiscountProgressViewModelProtocol? {
        didSet {
            guard let viewModel = viewModel else { return }
            tableView.reloadData()
            if !viewModel.loading && viewModel.items.count > 0 {
                tableView.refreshControl?.endRefreshing()
                activityIndicator.stopAnimating()
            }
        }
    }

    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .foregroundPrimary
        indicator.startAnimating()
        return indicator
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(DiscountProgressTableViewCell.self, forCellReuseIdentifier: DiscountProgressTableViewCell.cellReuseIdentifier)
        return tableView
    }()

    private let formatter = DateFormatter()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        formatter.timeZone = TimeZone.current
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupView() {
        backgroundColor = .backgroundPrimary
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        tableView.refreshControl = refresher
    }

    private func setupConstraints() {
        var constraints = [tableView.topAnchor.constraint(equalTo: topAnchor)]
        constraints.append(tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: bottomAnchor))

        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    @objc
private func reloadData() {
        self.viewModel?.reloadData()
    }

    private func monthName(date: Date) -> String {
        if let preferredLanguage = CommonConfigurator.shared.configuration.preferredLanguage {
            formatter.locale = Locale(identifier: preferredLanguage)
        }
        formatter.dateFormat = "MMMM yyyy"
        let s = formatter.string(from: date)
        return s
    }

    private func setupCell(cell: DiscountProgressTableViewCell, item: DiscountProgressChallange, atIndex index: Int) {
        guard let viewModel = self.viewModel else {
            return
        }
        if viewModel.highlitedItemIndex == index {
            cell.configureCurrenChalengeState()
        }
        cell.label.text = monthName(date: item.date ?? Date())
        if let offSeasonState = item.items?.first?.state, offSeasonState == .offSeason {
            cell.prepareUIForOffSeason()
        } else {
            cell.firstValue = "\(Int(item.items?.first?.discountAmount ?? 1))"
            cell.secondValue = "\(Int(item.items?.last?.discountAmount ?? 1))"
            cell.firstState = item.items?.first?.state ?? .missed
            cell.secondState = item.items?.last?.state ?? .missed
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension DiscountProgressView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let item = viewModel?.items.first,
                let cell = tableView.dequeueReusableCell(withIdentifier: DiscountProgressTableViewCell.cellReuseIdentifier) as? DiscountProgressTableViewCell else { return UITableViewCell() }
            if viewModel?.highlitedItemIndex == indexPath.row {
                cell.label.font = .stylingFont(.bold, with: 16)
                cell.configureCurrenChalengeState()
            }
            cell.start = true
            cell.secondValue = "\(Int(item.items?.first?.discountAmount ?? 1))"
            cell.secondState = item.items?.first?.state ?? .missed
            return cell
        } else {
            guard let item = viewModel?.items[indexPath.row],
                let cell = tableView.dequeueReusableCell(withIdentifier: DiscountProgressTableViewCell.cellReuseIdentifier) as? DiscountProgressTableViewCell else { return UITableViewCell() }
            setupCell(cell: cell, item: item, atIndex: indexPath.row)
            return cell
        }
    }
}
