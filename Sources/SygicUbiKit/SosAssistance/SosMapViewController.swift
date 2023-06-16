import Foundation
import MapKit

// MARK: - SosMapViewController

public class SosMapViewController: UIViewController {
    public var initialRegion: MKCoordinateRegion?

    var mapView: MKMapView?

    override public func loadView() {
        mapView = MKMapView()
        mapView?.showsUserLocation = true
        mapView?.delegate = self
        view = mapView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        guard let region = initialRegion else { return }
        mapView?.setRegion(region, animated: true)

        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIconCircular", in: .module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: MKMapViewDelegate

extension SosMapViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let annotationView = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.image = UIImage(named: "iconsMapStartLight", in: .module, compatibleWith: nil)
            return annotationView
        }
        return nil
    }
}
