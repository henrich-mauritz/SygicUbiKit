import Swinject
import UIKit
import MapKit

// MARK: - TripDetailViewController

public class TripDetailViewController: UIViewController, InjectableType {
    
    private var secondTime: Int = 2
    
    lazy var navigationDelegate: TriplogNavigationDelegate = {
        TriplogNavigationDelegate()
    }()

    public var viewModel: TripDetailViewModelProtocol? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    override public func loadView() {
        let detailView = container.resolve(TripDetailViewProtocol.self)
        detailView?.delegate = self
        view = detailView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.loadData()
         guard let detailView = view as? TripDetailViewProtocol else { return }
        detailView.viewModel = viewModel
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.tripDetailShown, parameters: nil)
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIconCircular", in: .module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        
        if let vehicle = viewModel?.currentFilteringVehicle {
            let indicatorView = VPVehicleIndicatorView(frame: .zero)
            indicatorView.update(with: vehicle.name.uppercased(), textColor: .buttonForegroundTertiaryPassive, backgroundColor: .buttonBackgroundTertiaryPassive)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicatorView)
        } else if let vehicleId = viewModel?.vehicleId {
            let vehicleRepo = container.resolveVehicleProfileRepo()
            if let vehicleFound = vehicleRepo.storedVehicles.first(where: { $0.publicId == vehicleId }) {
                let indicatorView = VPVehicleIndicatorView(frame: .zero)
                indicatorView.update(with: vehicleFound.name.uppercased(), textColor: .buttonForegroundTertiaryPassive, backgroundColor: .buttonBackgroundTertiaryPassive)
                viewModel?.currentFilteringVehicle = vehicleFound
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicatorView)
            }
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = nil
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.darkText]
    }

    override public func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.foregroundPrimary]
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: TripDetailViewControllerDelegate

extension TripDetailViewController: TripDetailViewControllerDelegate {
    public func shouldShowScoreDetail() {
        guard let destination = container.resolve(TriplogMapViewController.self), let scoreViewController = container.resolve(TripDetailScoreViewController.self) else { return }
        destination.mapViewModel = viewModel?.mapViewModel
        scoreViewController.viewModel = viewModel
        destination.contentController = scoreViewController
        navigationController?.pushViewController(destination, animated: true)
        resetNavDelegate()
    }

    public func showAboutYourScore() {
        let aboutYourSecoreController = AboutYourDrivescoreTableViewController(vehicleType: viewModel?.currentFilteringVehicle?.vehicleType ?? .car)
        navigationController?.pushViewController(aboutYourSecoreController, animated: true)
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: Styling.foregroundPrimary]
    }

    private func resetNavDelegate() {
        if navigationController?.delegate == nil {
            navigationController?.delegate = navigationDelegate
        }
    }
}

// MARK: TriplogViewModelDelegate

extension TripDetailViewController: TriplogViewModelDelegate {
    public func viewModelUpdated(_ sender: Any) {
        guard let detailView = view as? TripDetailViewProtocol else { return }
        detailView.viewModel = viewModel
        title = viewModel?.startTime.dayAndMonthFormat()
    }

    public func viewModelDidFail(with error: Error) {}
}

extension TripDetailViewController: TriplogMapViewDelegate {
    public func mapView(_ mapView: TriplogMapViewProtocol, didSelect event: TripDetailEvent, with type: EventType) {

    }
    
    public func reportAnnotationPlaced(coord: CLLocationCoordinate2D) {

    }
    
    public func mapRenderingFinished(image: UIImage) {
        //pockame na 2 volanie a mapu schovame a nechame obrazok.
        //trapas je ze keby sme tu nemali to protokolove peklo, tak by to bola uprava na 5 minut. teraz tu musim celu hierarchiu protokolov riesit.
        guard let detailView = view as? TripDetailViewProtocol else { return }
        secondTime -= 1
        if secondTime == 0 {
            detailView.replaceMapWithRenderedImage(image: image)
        }
    }
    
}
