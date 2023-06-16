import UIKit

// MARK: - VehicleProfileDetailError

public enum VehicleProfileDetailError: LocalizedError {
    case cantDeactivateCurrent

    public var errorDescription: String? {
        switch self {
        case .cantDeactivateCurrent:
            return "vehicleProfile.edit.errorDeactivate.description".localized
        }
    }

    public var errorTitle: String? {
        switch self {
        case .cantDeactivateCurrent:
            return "vehicleProfile.edit.errorDeactivate.title".localized
        }
    }

    public var icon: UIImage? {
        return UIImage(named: "warningXicon", in: .module, compatibleWith: nil)
    }
}

// MARK: - VehicleProfileDetailViewDelegate

public protocol VehicleProfileDetailViewDelegate: AnyObject {
    func didSelectEditNameVehicle()
    func presentError(with error: VehicleProfileDetailError)
}

// MARK: - VehicleProfileDetailView

public class VehicleProfileDetailView: UIView {
    public weak var delegate: VehicleProfileDetailViewDelegate?
    var viewModel: VehicleProfileEditViewModel? {
        didSet {
            //tableView.reloadData()
        }
    }

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.estimatedRowHeight = 70
        tv.rowHeight = UITableView.automaticDimension
        tv.backgroundColor = .backgroundPrimary
        tv.separatorStyle = .none
        tv.delegate = self
        tv.dataSource = self
        tv.register(VehicleDetailStateEnablerTableViewCell.self, forCellReuseIdentifier: VehicleDetailStateEnablerTableViewCell.identifier)
        tv.register(VehicleDetailNameTableViewCell.self, forCellReuseIdentifier: VehicleDetailNameTableViewCell.identifier)
        return tv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        backgroundColor = .backgroundPrimary
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        cover(with: tableView)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension VehicleProfileDetailView: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel else { return UITableViewCell() }
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: VehicleDetailStateEnablerTableViewCell.identifier)
                    as? VehicleDetailStateEnablerTableViewCell else { return UITableViewCell() }
            cell.switchControl.isEnabled = viewModel.hasMoreThanOneVehicle || viewModel.vehicle.state == .inactive
            cell.update(state: viewModel.state) { value in
                let newState: VehicleState = value ? .active : .inactive
                if !viewModel.canChangeState && newState == .inactive {
                    self.delegate?.presentError(with: .cantDeactivateCurrent)
                    cell.switchControl.isOn = !value
                    return
                }
                viewModel.state = newState
                viewModel.editVehcile { error in
                    if let error = error {
                        print("Error \(String(describing: error))")
                        //present some error maybe
                    } else {
                        tableView.reloadData()
                    }
                }
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: VehicleDetailNameTableViewCell.identifier)
                    as? VehicleDetailNameTableViewCell else { return UITableViewCell()}
            cell.update(with: viewModel.vehicle)
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            delegate?.didSelectEditNameVehicle()
        }
    }
}
