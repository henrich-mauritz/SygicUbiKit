import Foundation
import UIKit
import CoreLocation
import Driving

// MARK: - DrivingManager

public final class DrivingManager: NSObject {
    /// Sending notifications to the receiver about driving data changes
    public weak var delegate: DrivingModelDelegate? {
        didSet {
            guard delegate != nil, !initializationInProgress, !SygicDriving.sharedInstance().isInitialized else { return }
            setupSygicDriving()
        }
    }

    public let multicastDelegate: DrivingMulticastDelegate = DrivingMulticastDelegate()

    public static let shared: DrivingManager = DrivingManager()

    public var automaticTripDetection: Bool = false {
        didSet {
            guard SygicDriving.sharedInstance().isInitialized, SygicDriving.sharedInstance().isTripDetectionEnabled() != automaticTripDetection else { return }
            updateDBLibraryTripDetection()
        }
    }

    public var trackPerfectLocation: Bool = false {
        didSet {
            if trackPerfectLocation {
                if locationManager == nil {
                    locationManager = CLLocationManager()
                    locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                    locationManager?.delegate = self
                }
                locationManager?.startUpdatingLocation()
            } else {
                locationManager?.stopUpdatingHeading()
            }
            updateSpeedLimitProvider()
        }
    }

    /// An array of currently ongoing events, the latest event is at the end of the list
    public private(set) var events = [TripEvent]()
    /// State of the dricving lib detector
    public private(set) var detectorState: SygicDetectorState = .disoriented
    /// Is a trip currently running
    public var driving: Bool {
        SygicDriving.sharedInstance().isInitialized ? SygicDriving.sharedInstance().isTripRunning() : false
    }

    /// Locally computed trip results object
    public private(set) var finishedTripData: SygicDrivingTrip?
    /// Distance in a given trip in meters
    public private(set) var distanceTravelled: Double = 0
    /// Last known location recieved (CLLocationManager or SygicDriving when driving)
    public private(set) var lastKnownLocation: CLLocation?
    /// The current speed  in km/h
    @Clamping(min: 0, max: 300) public private(set) var currentSpeed: Int = 0
    /// Last known speed limit in km/h
    public private(set) var currentSpeedLimit: Double? {
        didSet {
            print("******** current speedLimit: \(String(describing: currentSpeedLimit))")
        }
    }

    public var configuration: DrivingConfiguration? {
        didSet {
            guard let configuration = configuration else { return }
            automaticTripDetection = configuration.automaticTripDetection
            if oldValue == nil {
                setupSygicDriving()
            }
        }
    }

    public private(set) var hasGPSSignal: Bool = true

    public var drivingLibInitialized: Bool {
        SygicDriving.sharedInstance().isInitialized
    }
    
    public var lastLocation: CLLocation?

    //MARK: - Private properties

    var currentAccuracy: Double = 0
    private var speedLimitsEnabled: Bool {
        ReachabilityManager.shared.status != .unreachable
    }

    private var locationManager: CLLocationManager?

    private let timestampValidThreshold: TimeInterval = 60

    private var positionPoolingTimer: Timer?

    private let kAccuracyThreshold: Double = 100

    private var initializationInProgress: Bool = false

    private var reinitTimer: Timer?

    private var reinitializationTimeIntervals: [TimeInterval] = [1, 30, 60, 600, 3600, 86400]

    private var shouldAddDashCamEvent: (enabled: Bool, withVision: Bool) = (false, false)

    override private init() {}

    deinit {
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
    }

    //MARK: - multicast support

    public func add(delegate: DrivingModelDelegate) {
        if !initializationInProgress, !SygicDriving.sharedInstance().isInitialized {
            setupSygicDriving()
        } else {
            multicastDelegate.add(delegate: delegate)
        }
    }

    public func remove(delegate: DrivingModelDelegate) {
        multicastDelegate.remove(delegate: delegate)
    }

    public func deinitSygicDriving() {
        configuration = nil
        SygicDriving.sharedInstance().delegate = nil
        if SygicDriving.sharedInstance().isInitialized {
            SygicDriving.sharedInstance().deinitialize()
        }
    }

    public func renewSecureIdIfNecesary(completion: @escaping ((NetworkError?) -> Void)) {
        guard let refreshDate = UserDefaults.standard.value(forKey: SecureUserId.secureUserIdRefreshDateKey) as? Date,
              let expirationDate = UserDefaults.standard.value(forKey: SecureUserId.secureUserIdExpirationDateKey) as? Date else {
                completion(nil)
                return
        }

        let now = Date()
        if now.compare(refreshDate) == .orderedDescending &&
            now.compare(expirationDate) == .orderedAscending ||
            now.compare(expirationDate) == .orderedDescending {
            SecureUserId.fetchUserId { result in
                switch result {
                case .success:
                    completion(nil)
                case .failure:
                    completion(NetworkError.expiredSecureUserId)
                }
            }
        } else {
            completion(nil)
        }
    }

    public func reset() {
        distanceTravelled = 0
        currentSpeed = 0
        currentSpeedLimit = nil
        events.removeAll()
        finishedTripData = nil
        multicastDelegate.drivingDataUpdated()
    }

    public func updateTailgatingTimeDistance(_ timeDistance: TimeInterval?) {
        guard SygicDriving.sharedInstance().isInitialized else { return }
        var numberDistance: NSNumber?
        if let timeDistance = timeDistance {
            numberDistance = NSNumber(value: timeDistance)
        }
        SygicDriving.sharedInstance().tailgating(withCarTimeDistance: numberDistance)
    }

    public func updateSpeedLimitFromVision(_ seenSpeedLimit: Double?) {
        updateSpeedLimit(seenSpeedLimit)
    }

    public func changeVehicleIdIfNecesary() {
        guard SygicDriving.sharedInstance().isInitialized, !SygicDriving.sharedInstance().isTripRunning() else { return }
       //Configuring if necesary the vehicle settings
        if let configuration = configuration,
           let currentVehicle = VehicleProfileModule.currentDrivingVehicle(),
           configuration.vehicleSettings.vehicleId != currentVehicle.publicId {
            configuration.vehicleSettings.vehicleId = currentVehicle.publicId
            switch currentVehicle.vehicleType {
            case .car:
                configuration.vehicleSettings.vehicleType = .car
            case .motorcycle:
                configuration.vehicleSettings.vehicleType = .motocycle
            default:
                configuration.vehicleSettings.vehicleType = .notSet
            }

            SygicDriving.sharedInstance().vehicleSettings = configuration.vehicleSettings
        }
    }

    func startTrip() {
        changeVehicleIdIfNecesary()
        SygicDriving.sharedInstance().startTrip()
    }

    func stopTrip() {
        guard SygicDriving.sharedInstance().isInitialized, SygicDriving.sharedInstance().isTripRunning() else { return }
        SygicDriving.sharedInstance().endTrip()
        NotificationCenter.default.post(name: .drivingTripManuallyStopNotification, object: nil)
        multicastDelegate.drivingManager(self, didEndTrip: nil)
    }

    public func addEventDashcam(enabled: Bool, hasVision: Bool) {
        if driving {
            SygicDriving.sharedInstance().addEventDashcamEnabled(enabled, withVision: hasVision)
        } else {
            shouldAddDashCamEvent = (enabled, hasVision)
        }
    }

    // MARK: -  Set up Sygic Driving Library

    private func setupSygicDriving() {
        guard let configuration = self.configuration, !initializationInProgress, !SygicDriving.sharedInstance().isInitialized else { return }
        initializationInProgress = true
        let storedId = Auth.shared.userId
        if let savedUserId = storedId {
            initializeSygicDrivingLibrary(with: configuration, userId: savedUserId)
            renewSecureIdIfNecesary(completion: { _ in })
        } else {
            SecureUserId.fetchUserId { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(userData):
                    if !SygicDriving.sharedInstance().isInitialized {
                        self.initializeSygicDrivingLibrary(with: configuration, userId: userData.userId)
                    }
                case let .failure(error):
                    print("DB lib refresh signedId ERROR: \(error.localizedDescription)")
                    self.initializationInProgress = false
                    self.multicastDelegate.drivingManager(self, didEncounter: error)
                    self.scheduleSetupIfNeeded()
                }
            }
        }
        updateSpeedLimitProvider()
    }

    private func initializeSygicDrivingLibrary(with configuration: DrivingConfiguration, userId: String) {
        do {
            try SygicDriving.sharedInstance().initialize(withClientId: configuration.clientID,
                                                         userId: userId,
                                                         licenseKey: configuration.drivingJWT,
                                                         configuration: configuration.configuration,
                                                         vehicleSettings: configuration.vehicleSettings)
            SygicDriving.sharedInstance().delegate = self
            initializationInProgress = false
            drivingLibraryInitializationFinished()
        } catch {
            print("DB lib ERROR: \(error.localizedDescription)")
            self.multicastDelegate.drivingManager(self, didEncounter: DrivingError.dbLibInit(error))
            self.showErrorModal()
            self.scheduleSetupIfNeeded()
        }
    }

    private func drivingLibraryInitializationFinished() {
        //updateSignedUserId()
        SygicDriving.sharedInstance().delegate = self
        SygicDriving.sharedInstance().developerMode = ADASDebug.enabled
        updateDBLibraryTripDetection()
        detectorState = SygicDriving.sharedInstance().detectorState()
        multicastDelegate.drivingDataUpdated()
    }

    private func scheduleSetupIfNeeded() {
        guard automaticTripDetection || delegate != nil else { return }
        guard reinitTimer == nil else { return } // already scheduled
        guard let reinitTime = reinitializationTimeIntervals.first else {
            multicastDelegate.drivingManager(self, didEncounter: DrivingError.cannotInitialize)
            return
        }
        reinitializationTimeIntervals.removeFirst() // to limit number of reinit attempts and prolong time intervals between them
        reinitTimer = Timer.scheduledTimer(withTimeInterval: reinitTime, repeats: false) { [weak self] _ in
            self?.reinitTimer = nil
            self?.setupSygicDriving()
        }
    }

    private func updateLocationInfo(_ location: CLLocation) {
        guard abs(location.timestamp.timeIntervalSinceNow) < timestampValidThreshold else { return }
        guard location.speed >= 0 else {
            hasGPSSignal = false
            multicastDelegate.drivingDataUpdated()
            return
        }

        let actualSpeed = Int(location.speed * 3.6)
        if actualSpeed >= configuration?.minSpeedThreshold ?? 0 {
            currentSpeed = actualSpeed
        } else {
            currentSpeed = 0
        }
        requestSpeedLimit(for: location)
        hasGPSSignal = true
        multicastDelegate.drivingDataUpdated()
    }

    @objc private func positionInvalidTimerExecution(timer: Timer) {
        DispatchQueue.main.async {
            self.hasGPSSignal = false
            self.positionPoolingTimer?.invalidate()
            self.positionPoolingTimer = nil
        }
    }

    private func updateSpeedLimit(_ speedLimit: Double?) {
        guard SygicDriving.sharedInstance().isInitialized,
              speedLimitsEnabled else {
            currentSpeedLimit = nil
            return
        }
        currentSpeedLimit = speedLimit
        if let speedLimit = speedLimit {
            SygicDriving.sharedInstance().setRoadLimit(speedLimit / 3.6) // km/h - m/s convertion
        }
        multicastDelegate.drivingDataUpdated()
    }

    private func updateSpeedLimitProvider() {
        //jur: asi sme mali nejaky dovod to robit takto ze ked nemame trip zapnuty tak zobrazujeme len vision
        //ale nedava to moc zmysel, lebo krizovatky nam speedlimit rusia. Cize defakto zobrazujeme userovi hovadiny
        //DrivingSpeedLimitManager.shared.speedLimitProviderEnabled = trackPerfectLocation && driving
        
        DrivingSpeedLimitManager.shared.speedLimitProviderEnabled = trackPerfectLocation || driving
    }

    private func updateDBLibraryTripDetection() {
        guard SygicDriving.sharedInstance().isInitialized else { return }
        SygicDriving.sharedInstance().enableTripDetection(automaticTripDetection)
    }

    private func requestSpeedLimit(for location: CLLocation) {
        guard speedLimitsEnabled else { return }
        if DrivingSpeedLimitManager.shared.delegate == nil {
            DrivingSpeedLimitManager.shared.delegate = self
        }
        DrivingSpeedLimitManager.shared.requestSpeedLimit(for: location)
    }

    private func showErrorModal() {
        guard let topViewController = UIApplication.shared.topMostViewController else {
            return
        }
        let title: String = "driving.generalError.title".localized
        let subtitle: String = "driving.generalError.subtitle".localized
        let actionTitle: String = "driving.generalError.button".localized
        let image: UIImage? = UIImage(named: "generalErrorImage", in: .module, compatibleWith: nil)

        let popUpController = StylingPopupViewController()
        let popUpViewModel = StylingPopUpViewModel(title: title, subtitle: subtitle, actionTitle: actionTitle, cancelTitle: nil, image: image)
        popUpViewModel.actionButtonAction = {
            topViewController.dismiss(animated: true, completion: nil)
        }
        popUpController.configure(with: popUpViewModel)
        topViewController.present(popUpController, animated: true, completion: nil)
    }

    public func permissionsUpdated() {
        guard driving else { return }
        let locationStatus = CLLocationManager().authorizationStatus
        if locationStatus != .authorizedAlways && locationStatus != .authorizedWhenInUse {
            stopTrip()
        }
    }

    public func tripModelHasChanged() {}
}

// MARK: SygicDrivingDelegate

extension DrivingManager: SygicDrivingDelegate {
    //MARK: - Events

    public func driving(_ driving: SygicDriving, eventStarted event: SygicTripEvent) {
        guard !event.eventIsBackComputed else {
            return
        }
        let event = TripEvent(event: event, status: .started)
        events.append(event)
        multicastDelegate.drivingDataUpdated()
    }

    public func driving(_ driving: SygicDriving, eventUpdate event: SygicTripEvent) {
        guard !event.eventIsBackComputed else {
            return
        }

        let event = TripEvent(event: event, status: .updated)
        guard let index = events.firstIndex(of: event) else { return }
        events[index] = event
        multicastDelegate.drivingDataUpdated()
    }

    public func driving(_ driving: SygicDriving, eventEnded event: SygicTripEvent) {
        let event = TripEvent(event: event, status: .updated)
        guard let index = events.firstIndex(of: event) else { return }
        events.remove(at: index)
        multicastDelegate.drivingDataUpdated()
    }

    public func driving(_ driving: SygicDriving, eventCanceled event: SygicTripEvent) {
        self.driving(driving, eventEnded: event)
    }

    //MARK: - TripLifeCycle

    public func driving(_ driving: SygicDriving, tripPossiblyStarted date: Date, location: CLLocation?) {
        print(">>>>>>\(#file), \(#function)<<<<<")
        NotificationCenter.default.post(name: .drivingTripPossiblyStarted, object: self)
    }

    public func driving(_ driving: SygicDriving, tripStartCancelled date: Date) {
        print(">>>>>>\(#file), \(#function)<<<<<")
        shouldAddDashCamEvent = (false, false)
        NotificationCenter.default.post(name: .drivingTripCanceled, object: self)
    }

    public func driving(_ driving: SygicDriving, tripDidStart date: Date, location: CLLocation?) {
        print(">>>>>>\(#file), \(#function)<<<<<")
        if shouldAddDashCamEvent.enabled {
            SygicDriving.sharedInstance().addEventDashcamEnabled(shouldAddDashCamEvent.enabled, withVision: shouldAddDashCamEvent.withVision)
        }
        updateSpeedLimitProvider()
        multicastDelegate.drivingManagerDidStartTrip(self)
        multicastDelegate.drivingDataUpdated()
        NotificationCenter.default.post(name: .drivingTripStarted, object: self)
    }

    public func driving(_ driving: SygicDriving, tripDidEnd date: Date, location: CLLocation?) {
        print(">>>>>>\(#file), \(#function)<<<<<")
        shouldAddDashCamEvent = (false, false)
        hasGPSSignal = true //just reseting defaults.
        events.removeAll()
        updateSpeedLimitProvider()
        multicastDelegate.drivingDataUpdated()
        NotificationCenter.default.post(name: .drivingTripEnded, object: self)
    }

    public func driving(_ driving: SygicDriving, tripDiscartedWith reason: SygicTripDiscartedReason) {
        print(">>>>>>\(#file), \(#function), reason:\(reason)<<<<<")
        shouldAddDashCamEvent = (false, false)
        hasGPSSignal = true //just reseting defaults.
        events.removeAll()
        updateSpeedLimitProvider()
        multicastDelegate.driving(self, tripDiscartedWith: reason)
        reset()
    }

    //MARK: - StateChanges

    public func driving(_ driving: SygicDriving, detectorStateChanged state: SygicDetectorState) {
        detectorState = state
        multicastDelegate.drivingDataUpdated()
    }

    public func driving(_ driving: SygicDriving, tripDistanceChanged distanceInMeters: Double) {
        distanceTravelled = distanceInMeters
        multicastDelegate.drivingDataUpdated()
    }

    //MARK: -  TripDataHandling

    public func driving(_ driving: SygicDriving, finalTripData trip: SygicDrivingTrip) {
        print(">>>>>>\(#file), \(#function), tripData:\(trip)<<<<<")
        finishedTripData = trip
        multicastDelegate.drivingManager(self, didEndTrip: trip)
    }

    public func driving(_ driving: SygicDriving, tripUploadedWithId tripId: String?, error errorReason: SygicTripUploadError, isSuccess success: Bool) {
        print(">>>>>>\(#file), \(#function) error:\(errorReason)<<<<<")
        multicastDelegate.drivingDataTripEnded(self, tripId: tripId, success: success, errorStatus: errorReason)
        reset()
    }

    public func driving(_ driving: SygicDriving, tripUploadedWithId tripId: String?, error: Error?) {
        print(">>>>>>\(#file), \(#function), error:\(String(describing: error)), uploadedID:\(String(describing: tripId))<<<<<")
        guard let error = error as NSError? else { return }
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.drivingTripUploadError,
                                                    parameters: [
                                                        AnalyticsKeys.Parameters.errorCodeKey: "\(error.code)",
                                                        AnalyticsKeys.Parameters.errorDescriptionKey: error.localizedDescription,
                                                        AnalyticsKeys.Parameters.networkTypeKey: ReachabilityManager.shared.status.rawValue,
                                                    ])
    }
}

// MARK: CLLocationManagerDelegate

//// Driving position delegate function to update current position
extension DrivingManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !driving else { return }
        var mostRecentLocation = locations.first
        for loc in locations {
            guard let mostRecent = mostRecentLocation else { break }
            if mostRecent.timestamp.compare(loc.timestamp) == .orderedAscending {
                mostRecentLocation = loc
            }
        }
        guard let location = mostRecentLocation else { return }
        lastLocation = location
        updateLocationInfo(location)
        //TODO: toto a celkovo rozlozenie kde je co treba updatnut.
        NotificationCenter.default.post(name: Notification.Name("SpeedFromGPS"), object: NSNumber(floatLiteral: location.speed))
        NotificationCenter.default.post(name: Notification.Name("GPSPositionReceivedNotificationKey"), object: location)
        
    }
}

// MARK: SygicPositioningDelegate

extension DrivingManager: SygicPositioningDelegate {
    public func driving(_ driving: SygicDriving, location: CLLocation) {
        guard SygicDriving.sharedInstance().isInitialized, driving.isTripRunning() else { return }
        updateLocationInfo(location)
        NotificationCenter.default.post(name: Notification.Name("SpeedFromGPS"), object: NSNumber(floatLiteral: location.speed))
        NotificationCenter.default.post(name: Notification.Name("GPSPositionReceivedNotificationKey"), object: location)
    }
}

// MARK: SygicSensorDelegate, SygicLoggingDelegate

extension DrivingManager: SygicSensorDelegate, SygicLoggingDelegate {
    // not used yet... needs to be implemented to set SygicDriving.sharedInstance().delegate
}

// MARK: DrivingSpeedLimitDelegate

extension DrivingManager: DrivingSpeedLimitDelegate {
    public func drivingSpeedLimitManager(_ manager: DrivingSpeedLimitManager, didUpdate speedLimit: Double?) {
        updateSpeedLimit(speedLimit)
    }
}
