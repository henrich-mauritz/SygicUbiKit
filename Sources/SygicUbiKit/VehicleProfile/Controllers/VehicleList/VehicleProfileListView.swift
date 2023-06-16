import UIKit

// MARK: - VehicleProfileListDelegate

protocol VehicleProfileListDelegate: AnyObject {
    func shouldPresentDetail(for vehicle: NetworkVehicle)
    func shouldPresentAddVehicle()
}

// MARK: - VehicleProfileListView

class VehicleProfileListView: UIView {
    //MARK: - properties

    weak var delegate: VehicleProfileListDelegate?
    var viewModel: VehicleListViewModel? {
        didSet {
            guard let viewModel = self.viewModel else {
                return
            }
            let reached = viewModel.numberOfRegisteredVehicles() >= viewModel.maxVehiclePerUser

            addVehicleButton.isHidden = reached
            maxVehicleReached.isHidden = !reached

            tableView.reloadData()
        }
    }

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.estimatedRowHeight = 60
        tv.rowHeight = UITableView.automaticDimension
        tv.tableHeaderView = headerView
        tv.dataSource = self
        tv.delegate = self
        tv.register(VehicleItemTableViewCell.self, forCellReuseIdentifier: VehicleItemTableViewCell.identifier)
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tv.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return tv
    }()

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "vehicleProfile.overview.subtitle".localized
        return label
    }()

    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 20))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cover(with: headerLabel, insets: NSDirectionalEdgeInsets(top: 5, leading: 24, bottom: 32, trailing: 24))
        return view
    }()

    private lazy var addVehicleButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.normal)
        button.titleLabel.text = "vehicleProfile.overview.addButton".localized.uppercased()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let gradientView: GradientDrawView = {
        let gradientColor = UIColor.backgroundPrimary
        let view = GradientDrawView()
        view.locations = [0, 0.6, 1]
        view.colors = [
            gradientColor.withAlphaComponent(0),
            gradientColor.withAlphaComponent(0.7),
            gradientColor,
        ]
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let maxVehicleReached: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary.withAlphaComponent(0.4)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isHidden = true
        label.text = "vehicleProfile.addVehicle1.maxReachedNote".localized
        return label
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let av = UIActivityIndicatorView(style: .large)
        av.color = Styling.foregroundPrimary
        av.translatesAutoresizingMaskIntoConstraints = false
        av.hidesWhenStopped = true
        return av
    }()

    //MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.layoutTableHeaderView()
    }

    private func setupUI() {
        backgroundColor = .backgroundPrimary
        tableView.backgroundColor = .backgroundPrimary
    }

    private func setupLayout() {
        var constraints: [NSLayoutConstraint] = []
        addSubview(tableView)
        addSubview(gradientView)
        addSubview(addVehicleButton)
        addSubview(maxVehicleReached)
        addSubview(activityIndicator)
        constraints.append(addVehicleButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40))
        constraints.append(addVehicleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40))
        constraints.append(addVehicleButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32))
        constraints.append(maxVehicleReached.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(maxVehicleReached.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(maxVehicleReached.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -28))
        constraints.append(gradientView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(gradientView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(gradientView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(gradientView.topAnchor.constraint(equalTo: addVehicleButton.topAnchor, constant: -40))
        constraints.append(tableView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: addVehicleButton.topAnchor, constant: -16))
        constraints.append(tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16))
        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))
        NSLayoutConstraint.activate(constraints)
        addVehicleButton.addTarget(self, action: #selector(VehicleProfileListView.addVehicleTap), for: .touchUpInside)
    }

    public func toggleActivityIndicator(animating: Bool) {
        if animating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    @objc
func addVehicleTap() {
        delegate?.shouldPresentAddVehicle()
    }

    public func reloadTableView() {
        guard let _ = viewModel else {
            return
        }
        tableView.reloadData()
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension VehicleProfileListView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRegisteredVehicles() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VehicleItemTableViewCell.identifier) as? VehicleItemTableViewCell,
              let vehicle = viewModel?.vehicle(at: indexPath.row) else {
            return UITableViewCell()
        }
        cell.update(with: vehicle)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let vehicle = viewModel?.vehicle(at: indexPath.row) else { return }
        delegate?.shouldPresentDetail(for: vehicle)
    }
}
