import CoreLocation
import MapKit
import MessageUI
import Swinject
import UIKit

// MARK: - SosAssistanceViewController

public class SosAssistanceViewController: UIViewController, InjectableType {
    public var viewModel: SosAssistanceViewModelProtocol? {
        didSet {
            viewModel?.delegate = self
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIconCircular", in: .module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager().authorizationStatus != .authorizedAlways && CLLocationManager().authorizationStatus != .authorizedWhenInUse {
            PopupManager.shared.presentModalPopup(SosAssistancePermissionPopupViewController(), on: self)
        }
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.assistanceShown, parameters: nil)
    }

    override public func loadView() {
        guard let sosView = container.resolve(SosAssistanceViewProtocol.self), let viewModel = container.resolve(SosAssistanceViewModelProtocol.self) else {
            view = UIView()
            return
        }
        self.viewModel = viewModel
        sosView.viewModel = viewModel
        sosView.delegate = self
        view = sosView
    }
    @objc private func backButtonTapped() {
        navigationController?.dismiss(animated: true)
    }
    
}

// MARK: SosAssistanceViewModelDelegate

extension SosAssistanceViewController: SosAssistanceViewModelDelegate {
    public func viewModelUpdated(_ sender: Any) {
        guard let view = view as? SosAssistanceView, let viewModel = viewModel else { return }
        view.viewModel = viewModel
    }
}

// MARK: SosAssistanceViewDelegate

extension SosAssistanceViewController: SosAssistanceViewDelegate {
    public func shouldShowMap(_ region: MKCoordinateRegion?) {
        let mapController = SosMapViewController()
        mapController.initialRegion = region
        navigationController?.pushViewController(mapController, animated: true)
    }

    public func shareLocation(_ location: CLLocation) {
        guard let viewModel = self.viewModel else {
            return
        }
        let locationdms = location.dmsFormat.replacingOccurrences(of: " ", with: "+")
        let locationdd = location.ddFormat.replacingOccurrences(of: " ", with: ", ")
        var mapsurl = "https://www.google.com/maps/place/\(locationdms)/@\(locationdd),17z/data=!4m5!3m4!1s0x0:0x0!8m2!3d\(location.coordinate.latitude)!4d\(location.coordinate.longitude)"
        mapsurl = mapsurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = String(format: "assistance.shareLocation.messageFormat".localized, viewModel.currentLocationString ?? location.ddFormat, Bundle.displayName ?? "", Date().hourInDayFormat(), mapsurl)

        let activityView = UIActivityViewController(activityItems: [body], applicationActivities: nil)
        activityView.excludedActivityTypes = [.addToReadingList, .assignToContact, .print, .saveToCameraRoll]
        present(activityView, animated: true, completion: nil)
    }
}

// MARK: MFMessageComposeViewControllerDelegate

extension SosAssistanceViewController: MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }
}
