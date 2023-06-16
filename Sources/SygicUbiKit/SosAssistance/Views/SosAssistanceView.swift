import Foundation
import MapKit
import Swinject

// MARK: - SosAssistanceView

public class SosAssistanceView: StylingBaseView, SosAssistanceViewProtocol {
    public weak var delegate: SosAssistanceViewDelegate?

    public var viewModel: SosAssistanceViewModelProtocol? {
        didSet {
            tableView.reloadData()
        }
    }

    public lazy var mapView: MKMapView = {
        let view = MKMapView()
        view.delegate = self
        view.showsUserLocation = true
        view.isUserInteractionEnabled = false
        topContent.insertSubview(view, at: 0)
        topContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:))))
        return view
    }()

    private let mapZoomDistance: CLLocationDistance = 1600 //m

    override public var tableStyle: UITableView.Style {
        get {
            .grouped
        }
        set {} //does nothing
    }

    override public init(frame: CGRect = .zero) {
        super.init(frame: frame)
        backgroundColor = .backgroundPrimary
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.register(SosAssistanceLocationCell.self, forCellReuseIdentifier: SosAssistanceLocationCell.reuseIdentifier)
        tableView.register(SosContactCell.self, forCellReuseIdentifier: SosContactCell.reuseIdentifier)
        setupConstraints()
        tableView.delaysContentTouches = false
        tableView.allowsSelection = false
        //To avoid delays we need to do this.
        //https://stackoverflow.com/questions/22924817/ios-delayed-touch-down-event-for-uibutton-in-uitableviewcell
        for case let scrollView as UIScrollView in tableView.subviews {
            scrollView.delaysContentTouches = false
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        topContent.insertSubview(mapView, at: 0)
        var constraints = [NSLayoutConstraint]()
        constraints.append(mapView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(mapView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(mapView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(mapView.bottomAnchor.constraint(equalTo: topContent.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    private func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }

    @objc private func mapTapped(_ sender: Any) {
        delegate?.shouldShowMap(mapView.region)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension SosAssistanceView: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewModel = viewModel else { return nil }
        let header = SosTableHeaderView()
        switch section {
        case 0:
            header.label.text = viewModel.currentLocationString != nil ? "assistance.currentLocation".localized : ""
        default:
            return nil
        }
        return header
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModel?.emergencyContacts.count ?? 0
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SosAssistanceLocationCell.reuseIdentifier, for: indexPath) as? SosAssistanceLocationCell, let viewModel = viewModel else { return UITableViewCell() }
            if viewModel.locationAvailable {
                cell.update(with: viewModel.currentLocationString)
                cell.updateActionButton(withTitle: "assistance.shareLocation.button".localized.uppercased()) {[weak self] in
                    guard let location = viewModel.location else { return }
                    self?.delegate?.shareLocation(location)
                }
            } else {
                cell.updateActionButton { [weak self] in
                    guard let self = self else { return }
                    self.openSettings()
                }
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SosContactCell.reuseIdentifier, for: indexPath) as? SosContactCell,
                let contact = viewModel?.emergencyContacts[indexPath.row] else {
                    return UITableViewCell()
            }
            cell.update(with: contact)
            return cell
        }
    }
}

// MARK: MKMapViewDelegate

extension SosAssistanceView: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let location = userLocation.location else { return }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: mapZoomDistance, longitudinalMeters: mapZoomDistance)
        mapView.setRegion(region, animated: false)
        viewModel?.updateLocation(location)
    }

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let annotationView = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.image = UIImage(named: "iconsMapStartLight", in: .module, compatibleWith: nil)
            return annotationView
        }
        return nil
    }
}

// MARK: - SosTableHeaderView

class SosTableHeaderView: UIView {
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textColor = .foregroundPrimary
        label.textAlignment = .center
        return label
    }()

    let margin: CGFloat = 16

    override init(frame: CGRect) {
        super.init(frame: frame)
        cover(with: label, insets: NSDirectionalEdgeInsets(top: margin, leading: margin, bottom: margin / 2, trailing: margin))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
