import UIKit

// MARK: - DiscountHowToView

public class DiscountHowToView: UIView, DiscountHowToViewProtocol {
    public var viewModel: DiscountHowToViewModelProtocol? {
        didSet {
            guard let viewModel = viewModel else { return }
            tableView.reloadData()
            if !viewModel.loading && viewModel.items.count > 0 {
                tableView.refreshControl?.endRefreshing()
                activityIndicator.stopAnimating()
            }
        }
    }

    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(DiscountHowToTableViewCell.self, forCellReuseIdentifier: DiscountHowToTableViewCell.cellReuseIdentifier)
        return table
    }()

    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .foregroundPrimary
        indicator.startAnimating()
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
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
        constraints.append(tableView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: bottomAnchor))

        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    @objc
private func reloadData() {
        self.viewModel?.reloadData()
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension DiscountHowToView: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel?.loading ?? true {
            return 0
        }
        return viewModel?.items.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel?.items[indexPath.row],
                let cell = tableView.dequeueReusableCell(withIdentifier: DiscountHowToTableViewCell.cellReuseIdentifier) as? DiscountHowToTableViewCell else { return UITableViewCell() }
        cell.title.text = item.title
        cell.subtitle.text = item.description
        return cell
    }
}
