import FloatingPanel
import UIKit

// MARK: - VehicleProfileCarSelectorViewController

public class VehicleProfileCarSelectorViewController: UIViewController {
    public var viewModel: VehicleListViewModel?
    public var listType: VehicleListType

    var sheetTitle: String = ""

    lazy var bottomSheet: FloatingPanelController = {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = Styling.cornerRadiusModalPopup
        appearance.backgroundColor = .backgroundModal
        let fpc = FloatingPanelController()
        fpc.surfaceView.appearance = appearance
        if let viewModel = viewModel {
            var extraPadding: CGFloat = sheetTitle.height(withConstrainedWidth: (UIApplication.shared.windows.first?.bounds.width ?? 320) - 32, font: UIFont.stylingFont(.thin, with: 30))

            fpc.layout = FloatingPanelBottomLayout(with: VehicleProfileCarSelectionView.kEstimatedRowHeight,
                                                   numberOfItems: viewModel.numberOfRegisteredVehicles(), extrapadding: extraPadding)
        }
        fpc.delegate = self
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.surfaceView.grabberHandle.isHidden = true
        let grabberView = UIImageView(image: UIImage(named: "dragger_down", in: .module, compatibleWith: nil))
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        grabberView.tintColor = .foregroundPrimary
        fpc.surfaceView.addSubview(grabberView)
        grabberView.topAnchor.constraint(equalTo: fpc.surfaceView.topAnchor, constant: 16).isActive = true
        grabberView.centerXAnchor.constraint(equalTo: fpc.surfaceView.centerXAnchor).isActive = true

        return fpc
    }()

    /// This is just a forwarding delegate
    public var delegate: VehicleProfileCarSelectionDelegate? {
        set {
            guard let view = self.view as? VehicleProfileCarSelectionView else {
                fatalError("The view of the vehicleProfile doesn't correspont")
            }
            view.delegate = newValue
        }
        get {
            guard let view = self.view as? VehicleProfileCarSelectionView else {
                fatalError("The view of the vehicleProfile doesn't correspont")
            }
            return view.delegate
        }
    }

    public init(with listType: VehicleListType) {
        self.listType = listType
        super.init(nibName: nil, bundle: nil)
        setupModal()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.listType = .all
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupModal()
    }

    private func setupModal() {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
    }

    /// sets the initial selected vehicle in the list for highlithing purposes
    /// if you don't call this method the highlighted vehicle witll be the default for driving
    /// - Parameter vehicle: vehicle to highlight
    public func setInitialSelection(with vehicle: VehicleProfileType) {
        guard let viewModel = self.viewModel else {
            return
        }
        viewModel.setSelectedListVehicle(with: vehicle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let vehicleView = VehicleProfileCarSelectionView(frame: .zero)
        vehicleView.tableView.delegate = self
        view = vehicleView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        viewModel = VehicleListViewModel(with: listType)
        viewModel?.delegate = self
        viewModel?.loadVehicles(cleanCache: false)
    }

    /// Will present modally the controller on a given frame
    /// - Parameters:
    ///   - frame: the frame the view will setup its bottom bounds
    ///   - controller: the controller that will present this car selction
    public func presentFrom(on controller: UIViewController, with title: String = "") {
        guard let view = self.view as? VehicleProfileCarSelectionView else { return }
        view.setListTitle(with: title)
        self.sheetTitle = title
        bottomSheet.contentViewController = self
        controller.present(bottomSheet, animated: true, completion: nil)
        self.view.backgroundColor = .backgroundModal
    }

    @objc
func close() {
        dismiss(animated: true, completion: nil)
    }

    @objc
func dismissFromDrag() {
        bottomSheet.removePanelFromParent(animated: true) {[weak self] in
            guard let self = self else { return }
            self.close()
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension VehicleProfileCarSelectorViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = self.view as? VehicleProfileCarSelectionView else { return false }
        let location = gestureRecognizer.location(in: view)
        return !view.frame.contains(location)
    }
}

// MARK: VehicleListViewModelDelegate

extension VehicleProfileCarSelectorViewController: VehicleListViewModelDelegate {
    public func didUpdate(viewModel: VehicleListViewModel) {
        guard let view = self.view as? VehicleProfileCarSelectionView else { return }
        view.viewModel = viewModel
    }

    public func didFailUpdate(viewModel: VehicleListViewModel, with error: Error) {
        //TODO: something really bad happened
    }
}

// MARK: FloatingPanelControllerDelegate

extension VehicleProfileCarSelectorViewController: FloatingPanelControllerDelegate {
    public func floatingPanel(_ vc: FloatingPanelController, layoutFor size: CGSize) -> FloatingPanelLayout {
        let extraPadding: CGFloat = sheetTitle.height(withConstrainedWidth: (UIApplication.shared.windows.first?.bounds.width ?? 320) - 32, font: UIFont.stylingFont(.thin, with: 30))
        if let viewModel = viewModel {
            return FloatingPanelBottomLayout(with: VehicleProfileCarSelectionView.kEstimatedRowHeight,
                                             numberOfItems: viewModel.numberOfRegisteredVehicles(), extrapadding: extraPadding)
        }
        return FloatingPanelBottomLayout(with: 0, numberOfItems: 0, extrapadding: extraPadding)
    }

    public func floatingPanelWillEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {
        if targetState.pointee == .tip {
           dismissFromDrag()
        }
    }
}

// MARK: UITableViewDelegate

extension VehicleProfileCarSelectorViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vehicle = self.viewModel?.vehicle(at: indexPath.row), let delegate = self.delegate else { return }
        if delegate.vehicleProfileSelectorIsOffSeason(for: vehicle), let parentController = bottomSheet.presentingViewController {
            if vehicle.vehicleType == .motorcycle {
                VehicleProfileModule.presentOffSeasonPopUp(on: parentController)
            }
        }
        if delegate.vehicleProfileSelectorShouldChangeSelectedVehicle(vehicle) {
            self.viewModel?.setVehicleAsDefault(vehicle)
            delegate.vehicleProfileSelectorDidChangeSelectedVehicle(vehicle)
            NotificationCenter.default.post(name: .applicationDidChangeVehicleNotification, object: nil, userInfo: ["vehicle": vehicle])
        }
        tableView.reloadData()
        dismissFromDrag()
    }
}
