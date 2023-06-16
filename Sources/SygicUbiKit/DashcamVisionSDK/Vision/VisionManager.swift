import Foundation
import SygicMaps
import VisionLib
import AVFoundation

// MARK: - VisionModelDelegate

public protocol VisionModelDelegate: AnyObject {
    func visionManagerDidProcessedImage()
    func visionManagerDidUpdateSpeedLimit(_ speedLimitVision: Double?,
                                          from source: SpeedLimitSource?)
    func visionManagerDidUpdateTailgating(_ isTailgating: Bool,
                                          vehicle: SYVisionVehicle?,
                                          tooClose: Bool,
                                          timeDistance: TimeInterval?)
    func beginEducation()
    func stopEducation()
    func setEducation(hidden: Bool)
}

public extension VisionModelDelegate {
    func visionManagerDidProcessedImage() {}
}

public protocol VisionProviderProtocol: AnyObject {
    func dashcamVisionHasDetectedClosingCar(at timeDistance: TimeInterval?)
    func dashcamVisionHasUpdatedSpeedLimit(_ speedLimit: Double?,
                                           source: SpeedLimitSource)
}

// MARK: - VisionManager

final class VisionManager: NSObject {
    static let shared: VisionManager = VisionManager()
    weak var delegate: VisionModelDelegate?
    public weak var publicDelegate: VisionProviderProtocol?
    var tailgatingThresholds: VisionTailgatingThresholds = DefaultTailgatingThresholds()
    var debugEnabled: Bool = ADASDebug.visionDebugEnabled
    var lastLocation: CLLocation?
    
    
    private lazy var tailgatingAudioPlayer: AVAudioPlayer? = {
        do {
            guard let tailgatingURL = Bundle.module.url(forResource: "sk_pulsar", withExtension: "mp3") else {
                return nil
            }
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.duckOthers, .defaultToSpeaker])
            let player = try AVAudioPlayer(contentsOf: tailgatingURL)
            player.delegate = self
            return player
        } catch {
            if ADASDebug.enabled {
                print("Couldn't load the audio warning sound")
            }
            return nil
        }
    }()

    var visionEnabled: Bool = false {
        didSet {
            if visionEnabled {
                resolveSpeedLimit()
                delegate?.stopEducation()
            } else {
                detectedSpeedSigns.removeAll()
                lastColidingVehicle = nil
                currentSpeedLimit = nil
                delegate?.visionManagerDidProcessedImage() //len aby sme prekreslili?
            }
        }
    }

    private(set) var currentSpeedLimit: SYSpeedLimitSourceInfo? {
        didSet {
            guard currentSpeedLimit != oldValue else { return }
            if let speedLimit = currentSpeedLimit,
               let source = SpeedLimitSource(with: speedLimit.sourceId) {
                let limit = Double(speedLimit.speedLimit)
                delegate?.visionManagerDidUpdateSpeedLimit(limit == 0 ? nil : limit, from: source)
                publicDelegate?.dashcamVisionHasUpdatedSpeedLimit(limit, source: source)
            } else {
                delegate?.visionManagerDidUpdateSpeedLimit(nil, from: nil)
                publicDelegate?.dashcamVisionHasUpdatedSpeedLimit(nil, source: .vision)
            }
        }
    }

    private(set) var detectedSpeedSigns: [SYVisionSign] = []

    private(set) var currentSpeed: Double?

    private(set) var lastColidingVehicle: SYVisionVehicle? {
        didSet {
            if let vehicle = lastColidingVehicle {
                publicDelegate?.dashcamVisionHasDetectedClosingCar(at: tailgatingVehicleTimeDistance)
                delegate?.visionManagerDidUpdateTailgating(true, vehicle: vehicle, tooClose: tailgatingTooClose, timeDistance: tailgatingVehicleTimeDistance)
                // Play sound if notificaiton is on
                guard let player = tailgatingAudioPlayer,
                      UserDefaults.dashcamTailgatingNotification == true,
                      oldValue == nil else {
                    return
                }
                try? AVAudioSession.sharedInstance().setActive(true)
                player.play()
            } else {
                publicDelegate?.dashcamVisionHasDetectedClosingCar(at: nil)
                delegate?.visionManagerDidUpdateTailgating(false, vehicle: nil, tooClose: false, timeDistance: nil)
            }
        }
    }

    private var tailgatingTooClose: Bool {
        guard let distance = tailgatingVehicleTimeDistance else { return false }
        return distance <= tailgatingThresholds.high
    }

    private var tailgatingVehicleTimeDistance: TimeInterval?

    private var navigationObserver: SYNavigationObserver?

    private let visionDispatchQueue = DispatchQueue(label: "vision.serial.queue")

    private var visionInitialized: Bool = false

    private var mapStreetInfo: SYStreetInfo? {
        didSet {
            //presli sme krizovatkou alebo sa zmenila ulica, potrebujeme zrusit limit ktory videl vision
            //extra speed limit konci krizovatkou, cize tam musi vision vidiet dalsiu znacku
            //do metody updateSpeedLimitLogic davame from: .vision, lebo to je to co chceme rusit.
            //nie je to to skade to prislo. To plati len pre metodu Add.
            guard let info = mapStreetInfo, let oldInfo = oldValue else { return }
            if info.isUrban != oldInfo.isUrban || info.city != oldInfo.city || info.street != oldInfo.street {
                updateSpeedLimitLogic(with: nil, from: .vision) //ok
            }
        }
    }

    private var speedLimitsEnabled: Bool {
        ReachabilityManager.shared.status != .unreachable
    }

    func processImage(_ sampleBuffer: CMSampleBuffer) {
        guard visionEnabled, visionInitialized else { return }
        SYVision.shared().processSampleBuffer(sampleBuffer)
    }

    @objc private func speedLimitChangedFromMap(notification: Notification) {
        if let number = notification.object as? NSNumber {
            let value = Double(number.floatValue)
            updateSpeedLimitLogic(with: value, from: .maps)
        }
    }
    
    @objc private func receivedSpeedFromGps(notification: Notification) {
        if let number = notification.object as? NSNumber {
            let value = Double(number.floatValue)
            currentSpeed = value
        }
    }
    
    @objc private func gpsPositionReceived(notification: Notification) {
        if let location = notification.object as? CLLocation {
            /*var l = CLLocation(coordinate: location.coordinate, altitude: location.altitude, horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, course: location.course, speed: 50, timestamp: location.timestamp)
            
            lastLocation = l
             */
            lastLocation = location
        }
    }
    //TODO: tu ma natekat speedlimit z mapy. nie z drivingu. nechapem preco vytvarame zbytocne zavislosti.
    /*
    func processDrivingSpeedInfo(speed: Double?, speedLimit: Double?) {
        currentSpeed = speed
        updateSpeedLimitLogic(with: speedLimit, from: .maps) //ok, kazdu sekundu..?
    }
     */

    //MARK: - Private mothods
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override private init() {
        super.init()
        visionDispatchQueue.async {
            self.setupVision()
        }
        setupLogic()
        SygicMapsInitializer.initializeSDK { [weak self] initialized in
            guard initialized else { return }
            self?.navigationObserver = SYNavigationObserver(delegate: self)
        }
        addNetworkStatusObserver()
        tailgatingAudioPlayer?.prepareToPlay()
        
        NotificationCenter.default.addObserver(self, selector: #selector(VisionManager.speedLimitChangedFromMap(notification:)), name: Notification.Name("MapSpeedLimitHasChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VisionManager.receivedSpeedFromGps(notification:)), name: Notification.Name("SpeedFromGPS"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VisionManager.gpsPositionReceived(notification:)), name: Notification.Name("GPSPositionReceivedNotificationKey"), object: nil)
    }

    private func setupVision() {
        guard let clientID = Bundle.main.infoDictionary?["DRIVING_UNIQUE_CLIENT_ID"] as? String,
              let jwt = Bundle.main.infoDictionary?["DRIVING_JWT"] as? String else {
            print("::: Vision was not initialized::, missing client id and jwt")
            return
        }
        do {
            let container = SYInjector.container
            var signRecognisionAllowed: Bool = false
            var tailgatingAllowed: Bool = false
            if let dashcamConfig = container.resolve(DashcamVisionConfigurable.self) {
                signRecognisionAllowed = dashcamConfig.signRecognitionEnabled
                tailgatingAllowed = dashcamConfig.tailgatingEnabled
            }
            try SYVision.shared().initialize(withClientId: clientID, licenseKey: jwt)
            SYVision.shared().config().object.active = tailgatingAllowed
            SYVision.shared().config().sign.active = signRecognisionAllowed
            SYVision.shared().config().road.active = tailgatingAllowed
            SYVision.shared().config().road.draw = false
            SYVision.shared().config().lane.active = tailgatingAllowed
            SYVision.shared().cameraConfig().focalLength = 2.6
            SYVision.shared().cameraConfig().sensorWidth = 4.1
            SYVision.shared().cameraConfig().sensorHeight = 2.05
            SYVision.shared().delegate = self
            visionInitialized = true
        } catch {
            print("::: Vision was not initialized:: problem upon initialization")
        }
    }

    private func setupLogic() {
        SYVisionLogic.shared().config().vehicleType = .car
        SYVisionLogic.shared().config().visionSpeedLimitId = SpeedLimitSource.vision.sourceId
        SYVisionLogic.shared().config().visionSpeedLimitPriority = SpeedLimitSource.vision.priority
        SYVisionLogic.shared().delegate = self
    }

    private func processVisionObjects(_ visionObjects: [SYVisionObject]) {
        guard visionEnabled else { return }
        
        var useLocation: Bool = false
        if let lastLocation = lastLocation {
            let currentDateTimestamp = Date().timeIntervalSince1970
            let locationTimestamp = lastLocation.timestamp.timeIntervalSince1970
            let diff = abs(currentDateTimestamp - locationTimestamp)
            if diff < 3 {
                useLocation = true
            }
        }
        //print("useLocation:\(useLocation), last location:\(String(describing: lastLocation))")
        SYVisionLogic.shared().add(visionObjects, with: useLocation ? lastLocation : nil)
        detectedSpeedSigns.removeAll()
        for visionObject in visionObjects {
            if let sign = visionObject as? SYVisionSign,
               sign.signType.speedLimit != nil,
               let speedLimit = sign.signType.speedLimit {
                //SYVisionLogic.shared().remove(1) //1 == .map, to nie je dolezite robit
                updateSpeedLimitLogic(with: speedLimit, from: .vision)
                detectedSpeedSigns.append(sign)
            }
        }
        delegate?.visionManagerDidProcessedImage()
    }

    private func updateSpeedLimitLogic(with limit: Double?, from source: SpeedLimitSource) {
        if let speedLimit = limit {
            //odkial info prislo
            let info = SYSpeedLimitSourceInfo()
            info.sourceId = source.sourceId
            info.priority = source.priority
            info.speedLimit = Int32(speedLimit)
            SYVisionLogic.shared().addSpeedLimit(info)
        } else {
            //source.sourceId koho informaciu mazem..
            SYVisionLogic.shared().remove(source.sourceId)
        }
    }

    private func resolveSpeedLimit(_ speedLimit: SYSpeedLimitSourceInfo? = nil) {
        guard visionEnabled,
              speedLimitsEnabled else {
            currentSpeedLimit = nil
            return
        }
        let resolvedSpeedLimit = speedLimit ?? SYVisionLogic.shared().getCurrentSpeedLimitInfo()
        currentSpeedLimit = resolvedSpeedLimit
    }

    private func addNetworkStatusObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged(_:)), name: .flagsChanged, object: nil)
    }

    @objc func networkStatusChanged(_ notification: Notification) {
        if ReachabilityManager.shared.status == .unreachable {
            // invalidate Vision speed limit when offline because we cannot tell exactly when user pass crossroad or change urban area without internet connection
            updateSpeedLimitLogic(with: nil, from: .vision) //ok
        }
        resolveSpeedLimit()
    }
}

// MARK: SYVisionDelegate

extension VisionManager: SYVisionDelegate {
    public func vision(_ vision: SYVision, didDetect visionObjects: [SYVisionObject], with info: SYVisionObjectsInfo) {
        DispatchQueue.main.async { [weak self] in
            self?.processVisionObjects(visionObjects)
        }
    }

    public func vision(_ vision: SYVision, didDetect visionRoad: SYVisionRoad?, with info: SYVisionRoadInfo) {
        
    }
}

// MARK: SYVisionLogicDelegate

extension VisionManager: SYVisionLogicDelegate {
    public func speedLimitChanged(_ speedLimit: SYSpeedLimitSourceInfo) {
        resolveSpeedLimit(speedLimit)
    }

    public func didDetectTailgating(_ object: SYVisionObject?, withTimeDistance timeDistance: Float) {
        tailgatingVehicleTimeDistance = TimeInterval(timeDistance)
        guard let vehicle = object as? SYVisionVehicle else {
            lastColidingVehicle = nil
            return
        }
        lastColidingVehicle = vehicle
    }
}

// MARK: SYNavigationDelegate

extension VisionManager: SYNavigationDelegate {
    public func navigation(_ observer: SYNavigationObserver, didStreetChange info: SYStreetInfo) {
        // TODO: didPassJunction method is not called without this method. delete after https://jira.sygic.com/browse/CI-1024 is resolved
        print("____ street info \(info.city ?? "No_city") _ \(info.street ?? "No_street")")
        mapStreetInfo = info
    }

    public func navigation(_ observer: SYNavigationObserver, didPassJunction type: SYStreetAttribute) {
        //TODO: notify delegate when crossroad pass
        print("_____ junction passed \(type)")
        updateSpeedLimitLogic(with: nil, from: .vision) //ok
        if VisionManager.shared.debugEnabled {
            ToastMessage.shared.present(message: ToastViewModel(title: "JUNCTION PASSED \(type)"), completion: nil)
        }
    }
}

// MARK: AVAudioPlayerDelegate

extension VisionManager: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully _: Bool) {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
