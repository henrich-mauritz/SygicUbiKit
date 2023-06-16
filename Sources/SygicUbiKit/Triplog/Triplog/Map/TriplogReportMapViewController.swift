import Foundation
import MapKit
import Swinject
import UIKit

// MARK: - TriplogReportMapViewControllerDelegate

protocol TriplogReportMapViewControllerDelegate: AnyObject {
    func didReportEvent(reported: Bool)
}

// MARK: - TriplogReportMapViewController

public class TriplogReportMapViewController: UIViewController, InjectableType {
    weak var delegate: TriplogReportMapViewControllerDelegate?
    public var viewModel: TripDetailReportViewModelProtocol? {
        didSet {
            viewModel?.getEventDetail()
        }
    }

    private var mapView: TriplogMapViewProtocol?

    private let reportView: MapReportView = {
        let view = MapReportView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundPrimary
        view.layer.cornerRadius = Styling.cornerRadiusModalPopup
        return view
    }()

    override public func loadView() {
        guard let map = container.resolve(TriplogMapViewProtocol.self) else {
            view = UIView()
            return
        }
        view = map
        mapView = map
        mapView?.isUserInteractionEnabled = true
        mapView?.delegate = self
        mapView?.isReportMap = true
        setupConstraints()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "triplog.mapReport.closeButton".localized, style: .plain, target: self, action: #selector(backButtonClicked))
        navigationItem.leftBarButtonItem = backButton
        guard let viewModel = viewModel,
            let coordinates = viewModel.tripCoordinates,
            let eventDetail = viewModel.eventDetail else { return }
        mapView?.addPolyline(with: coordinates)
        mapView?.addStartEndPinsOnMap(coordinates: viewModel.tripCoordinates)
        mapView?.addEventPins(with: .speeding, items: [eventDetail], withPolyline: true, animated: false)
        mapView?.setVisibleArea(coordinates: eventDetail.coordinates, margins: UIEdgeInsets(top: 80, left: 16, bottom: 168, right: 16), animated: true)
    }

    @objc
private func backButtonClicked() {
        dismiss(animated: true, completion: nil)
    }

    private func setupConstraints() {
        guard let mapView = mapView else { return }
        reportView.delegate = self
        mapView.addSubview(reportView)
        var constraints = [reportView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 16)]

        constraints.append(reportView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16))
        constraints.append(reportView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -50))

        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: TripDetailReportViewModelDelegate

extension TriplogReportMapViewController: TripDetailReportViewModelDelegate {
    public func viewModelUpDated() {
        guard let viewModel = viewModel else { return }
        mapView?.viewModel = viewModel
    }
}

// MARK: TriplogMapViewDelegate

extension TriplogReportMapViewController: TriplogMapViewDelegate {
    public func mapView(_ mapView: TriplogMapViewProtocol, didSelect event: TripDetailEvent, with type: EventType) {}

    public func reportAnnotationPlaced(coord: CLLocationCoordinate2D) {
        reportView.showButton = true
        viewModel?.reportPoint = coord
    }
    
    public func mapRenderingFinished(image: UIImage) {
        //do nothing
    }
}

// MARK: MapReportViewDelegate

extension TriplogReportMapViewController: MapReportViewDelegate {
    public func shouldShowReport() {
        guard let reportViewModel = viewModel,
            let destination = container.resolve(TripDetailReportViewControllerProtocol.self) else { return }
        destination.viewModel = reportViewModel
        destination.delegate = self
        present(destination, animated: true, completion: nil)
    }
}

// MARK: TripDetailReportViewControllerDelegate

extension TriplogReportMapViewController: TripDetailReportViewControllerDelegate {
    public func reportSubmited(result: Result<Bool, Error>) {
        let controller = presentingViewController
        var alertText: String = ""
        switch result {
        case let .failure(error):
            if let error = error as? NetworkError, error.httpErrorCode == 422 {
                alertText = "triplog.reportSubmitted.alreadyReportedTitle".localized
            } else {
                alertText = "triplog.reportSubmitted.tryAgainTitle".localized
            }
        case let .success(reported):
            alertText = "triplog.reportSubmitted.successTitle".localized
            delegate?.didReportEvent(reported: reported)
        }
        controller?.dismiss(animated: true, completion: {
            let alert = UIAlertController(title: alertText, message: nil, preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "triplog.reportSubmitted.dismissButton".localized.uppercased(), style: UIAlertAction.Style.default, handler: nil))
            controller?.present(alert, animated: true, completion: nil)
        })
    }
}
