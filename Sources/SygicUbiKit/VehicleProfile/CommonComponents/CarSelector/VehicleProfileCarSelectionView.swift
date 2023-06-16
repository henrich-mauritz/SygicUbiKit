import UIKit

// MARK: - VehicleProfileCarSelectionDelegate

public protocol VehicleProfileCarSelectionDelegate: AnyObject {
    /// Delegates must implement this option to have the selector store the selected vehicle
    /// Otherwise it will do nothing and rely the logic to the delegate
    /// For now this method wont be called, but its ther edelcared in case another app will requiere this logic
    func vehicleProfileSelectorShouldChangeSelectedVehicle(_ vehicle: VehicleProfileType) -> Bool
    func vehicleProfileSelectorDidChangeSelectedVehicle(_ vehicle: VehicleProfileType)
    func vehicleProfileSelectorIsOffSeason(for vehicle: VehicleProfileType) -> Bool
}

public extension VehicleProfileCarSelectionDelegate {
    func vehicleProfileSelectorShouldChangeSelectedVehicle(_ vehicle: VehicleProfileType) -> Bool { true }
    func vehicleProfileSelectorDidChangeSelectedVehicle(_ vehicle: VehicleProfileType) {}
    func vehicleProfileSelectorIsOffSeason(for vehicle: VehicleProfileType) -> Bool { false }
}

// MARK: - VehicleProfileCarSelectionView

public class VehicleProfileCarSelectionView: UIView {
    public var viewModel: VehicleListViewModel?
    public weak var delegate: VehicleProfileCarSelectionDelegate?
    public static let kEstimatedRowHeight: CGFloat = 60
    private let headerMargins: CGFloat = 32
    var initialSelection: Int = -1

    lazy var tableView: UITableView = {
        let windowFrame = UIApplication.shared.windows.first?.frame ?? .zero
        let tv = UITableView(frame: CGRect(x: 0, y: 0, width: windowFrame.width, height: 100))
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = VehicleProfileCarSelectionView.kEstimatedRowHeight
        tv.register(VehicleProfileCarSelectionCell.self, forCellReuseIdentifier: VehicleProfileCarSelectionCell.identifier)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: safeAreaInsets.bottom, right: 0)
        tv.scrollIndicatorInsets = tv.contentInset
        return tv
    }()

    private lazy var tableHeaderView: UIView = {
        let windowFrame = UIApplication.shared.windows.first?.frame ?? .zero
        let view = UIView(frame: CGRect(x: 0, y: 0, width: windowFrame.width, height: 100))
        view.cover(with: titleLabel, insets: NSDirectionalEdgeInsets(top: headerMargins, leading: headerMargins, bottom: headerMargins, trailing: headerMargins))
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.thin, with: 30)
        label.textColor = Styling.foregroundPrimary
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundModal
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: 90).isActive = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        backgroundColor = .backgroundModal
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        containerView.cover(with: tableView)
        cover(with: containerView, insets: NSDirectionalEdgeInsets(top: 32, leading: 0, bottom: 32, trailing: 0))
    }

    func canDismissfromTouch(at touchPosition: CGPoint) -> Bool {
        return false
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if tableView.tableHeaderView == nil {
            tableView.tableHeaderView = tableHeaderView
            tableView.layoutTableHeaderView()
        }
    }

    public func setListTitle(with title: String) {
        titleLabel.text = title
    }
}

// MARK: UITableViewDataSource

extension VehicleProfileCarSelectionView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.numberOfRegisteredVehicles()
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel, let vehicle = viewModel.vehicle(at: indexPath.row) else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VehicleProfileCarSelectionCell.identifier) as? VehicleProfileCarSelectionCell else {
            fatalError("No cell was registered")
        }
        cell.update(with: vehicle, selected: indexPath.row == viewModel.selectedVehicleIndex)
        return cell
    }
}
