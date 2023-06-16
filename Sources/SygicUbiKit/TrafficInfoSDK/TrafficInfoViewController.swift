//
//  TrafficInfoViewController.swift
//  TrafficInfoSDK
//
//  Created by Juraj Antas on 25/10/2022.
//

import Foundation
import UIKit
import MapKit

public class TrafficInfoViewController: BaseViewController, MKMapViewDelegate, TrafficInfoViewModelDelegate, TrafficInfoFilterViewControllerDelegate, CLLocationManagerDelegate {
    private var locationButton: UIButton!
    private var filterButton: UIButton!
    private var rotateToNorthButton: UIButton!
    private var stackViewForButtons: UIStackView!
    
    private var mapView: MKMapView!
    
    private var viewModel: TrafficInfoViewModel
    private var dataLoaded: Bool = false
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = false
        return locationManager
    }()
    
    private var userDefaultKeyForShowFilterOnce: String = "userDefaultKeyForShowFilterOnce"
    
    public required init(model: TrafficInfoViewModel) {
        self.viewModel = model
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = ""
        view.backgroundColor = .backgroundPrimary
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIconCircular", in: .module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
    
        reloadData()
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    func reloadData() {
        showActivityIndicator()
        viewModel.reloadData()
    }
   
    func buildUI() {
        guard dataLoaded == true else {
            return
        }
        
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsScale = false
        mapView.showsCompass = false
        mapView.isRotateEnabled = true
        mapView.showsTraffic = true
        
        locationButton = UIButton(type: .system)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.setBackgroundImage(UIImage(named: "circleButtonMyPosition", in: .module, compatibleWith: nil), for: .normal)
        locationButton.setBackgroundImage(UIImage(named: "circleButtonMyPosition", in: .module, compatibleWith: nil), for: .selected)
        
        filterButton = UIButton(type: .system)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.setBackgroundImage(UIImage(named: "circleButtonFilter", in: .module, compatibleWith: nil), for: .normal)
        
        rotateToNorthButton = UIButton(type: .system)
        rotateToNorthButton.translatesAutoresizingMaskIntoConstraints = false
        rotateToNorthButton.setBackgroundImage(UIImage(named: "circleButtonNorth", in: .module, compatibleWith: nil), for: .normal)
                
        stackViewForButtons = UIStackView()
        stackViewForButtons.translatesAutoresizingMaskIntoConstraints = false
        stackViewForButtons.axis = .vertical
        stackViewForButtons.spacing = 0
        
        locationButton.onTapped { [weak self] in
            guard let self = self else {return}
            self.locationButtonTapped()
        }
        
        filterButton.onTapped { [weak self] in
            guard let self = self else {return}
            self.filterButtonTapped()
        }
        
        rotateToNorthButton.onTapped { [weak self] in
            guard let self = self else {return}
            self.rotateToNorthButtonTapped()
        }
    
        view.addSubview(mapView)
        view.addSubview(stackViewForButtons)
        
        stackViewForButtons.addArrangedSubviews([rotateToNorthButton, locationButton, filterButton])
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterButton.heightAnchor.constraint(equalToConstant: 56),
            filterButton.widthAnchor.constraint(equalToConstant: 56),
            
            locationButton.heightAnchor.constraint(equalToConstant: 56),
            locationButton.widthAnchor.constraint(equalToConstant: 56),
            
            rotateToNorthButton.heightAnchor.constraint(equalToConstant: 56),
            rotateToNorthButton.widthAnchor.constraint(equalToConstant: 56),
            
            stackViewForButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            stackViewForButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        
        mapView.register(
            TrafficInfoMapItemAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: TrafficInfoMapItemAnnotationView.reuseIdentifier)
        mapView.register(TrafficInfoClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: TrafficInfoClusterAnnotationView.reuseIdentifier)
        
        mapView.layoutMargins.bottom = 70
    
        updateLocationButtonState()
        updateButtonStatus()
        
        if UserDefaults.standard.bool(forKey: userDefaultKeyForShowFilterOnce) == false {
            DispatchQueue.main.async { [weak self] in
                self?.filterButtonTapped()
            }
            UserDefaults.standard.set(true, forKey: userDefaultKeyForShowFilterOnce)
        }
    }
    
    //MARK: - button actions
    func locationButtonTapped() {
        locationManager.requestLocation()
        
        let status = CLLocationManager().authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            fallthrough
        case .denied:
            showAllowLocationDialog()
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            fallthrough
        case .authorized:
            locationManager.requestLocation()
        @unknown default:
            showAllowLocationDialog()
        }
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: viewModel.userCoordinate.latitude, longitude: viewModel.userCoordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
    }
    
    func filterButtonTapped() {
        let vc = TrafficInfoFilterViewController(model: viewModel.filterModel, delegate: self)
        self.presentAsSheet(viewController: vc)
    }
    
    func rotateToNorthButtonTapped() {
        let cameraCopy = mapView.camera
        cameraCopy.heading = 0
        cameraCopy.pitch = cameraCopy.pitch+0.1
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [weak self] in
            guard let self = self else {return}
            self.mapView.setCamera(cameraCopy, animated: true)
        }
    }
    
    func displayTrafficInfoDetail(index: Int) {
        let detailData = viewModel.selectedItems[index]
        let vc = TrafficInfoDetailViewController(model: detailData)
        vc.onCloseBlock = { [weak self] in
            guard let self = self else {return}
            self.mapView.deselectAnnotation(nil, animated: true)
        }
        self.presentAsSheet(viewController: vc)
    }
    
    func displayList(model: [TrafficInfoData]) {
        let vc = TrafficInfoListMapItemsViewController(model: model)
        vc.onCloseBlock = { [weak self] in
            guard let self = self else {return}
            self.mapView.deselectAnnotation(nil, animated: true)
        }
        
        vc.onPresentDetail = { [weak self] model in
            guard let self = self else {return}
            let vc = TrafficInfoDetailViewController(model: model)
            self.presentAsSheet(viewController: vc)
        }
        self.presentAsSheet(viewController: vc)
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    //MARK:  - location delegate
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = CLLocationManager().authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
        
        updateLocationButtonState()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let status = CLLocationManager().authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
        
        updateLocationButtonState()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard dataLoaded == true else { return }
        
        guard let location = locations.first else {
            return
        }
        
        viewModel.userCoordinate = location.coordinate
        viewModel.filter(coordinate: location.coordinate, zoomMode: .location(location: location))
    }
    
    func updateLocationButtonState() {
        guard dataLoaded == true else { return }
        
        let status = CLLocationManager().authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationButton.setImage(UIImage(named:"location_detected"), for: .normal)
            locationButton.tintColor = .foregroundTertiary
        }
        else {
            locationButton.setImage(UIImage(named:"location_detect"), for: .normal)
            locationButton.tintColor = .foregroundTertiary
        }
    }
    
    func showAllowLocationDialog() {
        //TODO: v dizajne chyba
        /*
        let vc = AlertViewController(title: L10n.Itr.FillClaim.Location.PermissionSettings.title,
                                     subtitle: L10n.Itr.FillClaim.Location.PermissionSettings.subtitle,
                                     confirmButtonTitle: L10n.Itr.FillClaim.Location.PermissionSettings.accept.uppercased(),
                                     cancelButtonTitle: L10n.Itr.FillClaim.Location.PermissionSettings.reject.uppercased(),
                                     confirmButtonStyle: .normalPrimary, cancelButtonStyle: .normalSecondary)
        vc.confirmAction = {  [weak vc] in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            vc?.dismiss(animated: true)
        }
        
        vc.cancelAction = { [weak vc] in
            vc?.dismiss(animated: true)
        }
        self.present(vc, animated: true)
         */
    }
    
    //MARK: - view model updated
    
    func viewModelUpdated(error: Error?) {
        self.hideActivityIndicator()
        
        let status = CLLocationManager().authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            fallthrough
        case .authorized:
            locationManager.requestLocation()
        @unknown default:
            break
        }
        
        if error != nil {
            let error = NetworkError.error(from: error as? NSError)
            let style: MessageViewModel.MessageViewModelStyle = error == .noInternetConnection ? .noInternet : .error
            let messageViewModel = MessageViewModel.viewModel(with: style)
            presentErrorView(with: messageViewModel)
            return
        }
        else {
            dataLoaded = true
            dismissErrorView()
        }
        
        buildUI()
    }
    
    func viewModelFiltered(zoomMode: TRMapZoomMode) {
        updateData(zoomMode: zoomMode)
    }
    
    var annotations: [TrafficInfoMapItem] = []
    
    func updateData(zoomMode: TRMapZoomMode) {
        
        //delete all old data
        mapView.removeAnnotations(annotations)
        annotations = []
        
        //put data on map
        var coordinates: [CLLocationCoordinate2D] = []
        for (index,item) in viewModel.selectedItems.enumerated() {
            let lat  = item.payload.position.latitude
            let long = item.payload.position.longitude
            
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
            coordinates.append(coord)
            let annotation = TrafficInfoMapItem(coordinate: coord, type: item.type, index: index)
            annotations.append(annotation)
            mapView.addAnnotation(annotation)
        }
        
        switch zoomMode {
        case .allVisiblePins:
            let rects = coordinates.map { MKMapRect(origin: MKMapPoint($0), size: MKMapSize()) }
            let fittingRect = rects.reduce(MKMapRect.null) { $0.union($1) }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 100000000)) {
                self.mapView.setVisibleMapRect(fittingRect, edgePadding: UIEdgeInsets(top: 100, left: 10, bottom: 100, right: 10), animated: false)
            }
        case .location(let location):
            let regionRadius = 1000.0 // in meters
            let coordinateRegion = MKCoordinateRegion( center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius )
            self.mapView.setRegion( coordinateRegion, animated: true)
        case .region(let region):
            let newRegion = viewModel.includeAtLeastOneBranch(region: region)
            let mkregion = MKCoordinateRegion(center: newRegion.center, latitudinalMeters: newRegion.radius, longitudinalMeters: newRegion.radius)
            let bottomInset: CGFloat = 130
            
            self.mapView.setVisibleMapRect(mkregion.rect, edgePadding: UIEdgeInsets(top: 170, left: 10, bottom: bottomInset, right: 10), animated: true)
        case .noChange:
            break
        }
    }

    //MARK: - Filter pannel delegated
    func filterSelectionChanged() {
        viewModel.filter(coordinate: viewModel.userCoordinate, zoomMode: .noChange)
    }
    
    //MARK: - Map annotations
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("selected annotation: \(view)")
        if let pinView = view as? TrafficInfoMapItemAnnotationView {
            if let a = pinView.annotation as? TrafficInfoMapItem {
                displayTrafficInfoDetail(index: a.index)
            }
        }
        else if view is TrafficInfoClusterAnnotationView {
            // if the user taps a cluster, zoom in
            let currentSpan = mapView.region.span
            if currentSpan.latitudeDelta < 0.001 {
                //display list detail
                if let cluster = view.annotation as? MKClusterAnnotation {
                    let model: [TrafficInfoData] = cluster.memberAnnotations.map { annotation in
                        return self.viewModel.selectedItems[(annotation as! TrafficInfoMapItem).index]
                    }
                    displayList(model: model)
                }
            }
            else {
                //zoom more
                let zoomSpan = MKCoordinateSpan(latitudeDelta: currentSpan.latitudeDelta / 2.0, longitudeDelta: currentSpan.longitudeDelta / 2.0)
                let zoomCoordinate = view.annotation?.coordinate ?? mapView.region.center
                let zoomed = MKCoordinateRegion(center: zoomCoordinate, span: zoomSpan)
                mapView.setRegion(zoomed, animated: true)
            }
            //lebo ked sa raz selektne, dalsi tap uz nebere. cize treba deselektnut.
            mapView.deselectAnnotation(nil, animated: false)
        }
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let itemAnnotation = annotation as? TrafficInfoMapItem {
            let a = mapView.dequeueReusableAnnotationView(withIdentifier: TrafficInfoMapItemAnnotationView.reuseIdentifier, for: itemAnnotation) as! TrafficInfoMapItemAnnotationView
            
            a.clusteringIdentifier = "MyClusterViewIdentifier"
            a.canShowCallout = false
            
            a.image = TrafficInfoMapItem.imageForType(type: itemAnnotation.type)
            /* test animation for important markers.
            let e = TrafficInfoMapItem.imageViewForType(type: itemAnnotation.type)
            
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.duration = 1.0
            animation.repeatCount = .greatestFiniteMagnitude
            //animation.autoreverses = true
            animation.fromValue = NSNumber(value: 1.0)
            animation.toValue = NSNumber(value: 2.5)
            e.layer.add(animation, forKey: "pulse")
            
            let animation2 = CABasicAnimation(keyPath: "opacity")
            animation2.duration = 1.0
            animation2.repeatCount = .greatestFiniteMagnitude
            animation2.fromValue = NSNumber(value: 1.0)
            animation2.toValue = NSNumber(value: 0.0)
            e.layer.add(animation2, forKey: "opacity")
            
            a.addSubview(e)
            e.sendSubviewToBack(e)
            */
            return a
        }
        
        if let cluster = annotation as? MKClusterAnnotation {
            let a = mapView.dequeueReusableAnnotationView(withIdentifier: TrafficInfoClusterAnnotationView.reuseIdentifier, for: cluster)
            return a
        }
        
        return nil
    }
    
    var isProgramaticMapMovement: Bool = false
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if !isProgramaticMapMovement {
            
            isProgramaticMapMovement = false
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateButtonStatus()
    }
    
    func updateButtonStatus() {
        //use for displaying my location button when my location is out of view
        if mapView.isUserLocationVisible {
            locationButton.isHidden = true
        }
        else {
            locationButton.isHidden = false
        }
        
        if mapView.camera.heading != 0.0 {
            rotateToNorthButton.isHidden = false
        }
        else {
            rotateToNorthButton.isHidden = true
        }
    }
    
}

extension MKCoordinateRegion {
    public var rect : MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: self.center.latitude + (self.span.latitudeDelta/2), longitude: self.center.longitude - (self.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: self.center.latitude - (self.span.latitudeDelta/2), longitude: self.center.longitude + (self.span.longitudeDelta/2))
        
        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)
        
        return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
    }
    
}
