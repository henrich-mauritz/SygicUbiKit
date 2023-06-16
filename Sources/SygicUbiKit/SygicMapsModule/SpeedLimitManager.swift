import CoreLocation
import Foundation
import SygicMaps

// MARK: - DrivingSpeedLimitDelegate

public protocol DrivingSpeedLimitDelegate: AnyObject {
    func drivingSpeedLimitManager(_ manager: DrivingSpeedLimitManager, didUpdate speedLimit: Double?)
}

// MARK: - DrivingSpeedLimitManager

public class DrivingSpeedLimitManager: NSObject {
    //TODO: bracho, preco si singleton? A preco extra?
    public static let shared = DrivingSpeedLimitManager()

    public weak var delegate: DrivingSpeedLimitDelegate? {
        didSet {
            if delegate != nil {
                if SYContext.isInitialized() {
                    speedLimitProvider = SYNavigationObserver(delegate: self)
                    print("DrivingSpeedLimitManager delegate set")
                } else {
                    initializeLibraryIfNeeded { [weak self] in
                        guard let self = self else {return}
                        print("DrivingSpeedLimitManager delegate set and lib initialized")
                        self.speedLimitProvider = SYNavigationObserver(delegate: self)
                    }
                }
            } else {
                speedLimitProvider = nil
            }
        }
    }

    public var speedLimitProviderEnabled: Bool = false {
        didSet {
            //print("Old speedLimitProviderEnabled:\(oldValue), new: \(speedLimitProviderEnabled)")
            guard speedLimitProviderEnabled != oldValue else {
                return
            }
            if speedLimitProviderEnabled {
                //TODO: debilne riesenie
                initializeLibraryIfNeeded { [weak self] in
                    guard let self = self else {return}
                    self.positioningProvider?.start()
                    self.sygicMapsDefaultPositionProvider?.startUpdatingPosition()
                    if let lastLocation = self.lastKnownLocation {
                        self.requestSpeedLimit(for: lastLocation)
                    }
                }
                //---^^^ vid hore ^^^--- mas to tu 2x.
                positioningProvider?.start()
                sygicMapsDefaultPositionProvider?.startUpdatingPosition()
                if let lastLocation = lastKnownLocation {
                    requestSpeedLimit(for: lastLocation)
                }
            } else {
                positioningProvider?.stop()
                sygicMapsDefaultPositionProvider?.stopUpdatingPosition()
            }
        }
    }

    private var sygicMapsDefaultPositionProvider: SYPositioning?
    private var positioningProvider: SYCustomPositionSource?
    private var speedLimitProvider: SYNavigationObserver?
    private var lastKnownLocation: CLLocation?
    private let timestampValidThreshold: TimeInterval = 60

    override private init() {
        super.init()
    }

    public func requestSpeedLimit(for location: CLLocation) {
        lastKnownLocation = location
        guard SYContext.isInitialized() else { return }
        guard speedLimitProviderEnabled else { return }
        positioningProvider?.updateCurrentPosition(sdkPosition(from: location))
        positioningProvider?.updateCurrentCourse(sdkCource(from: location))
    }

    public func initializeLibraryIfNeeded(completion: @escaping () -> Void) {
        guard !SYContext.isInitialized() else { return }
        SygicMapsInitializer.initializeSDK { [weak self] success in
            guard success else { return }
            self?.initializationFinished()
            completion()
        }
    }

    private func initializationFinished() {
        speedLimitProvider = SYNavigationObserver(delegate: self)

//        positioningProvider = SYCustomPositionSource()
//        SYPositioningManager.shared().dataSource = positioningProvider
//        if speedLimitProviderEnabled {
//            positioningProvider?.start()
//        }
        //TODO: bug in SygicMaps cause we are not getting junction and street updates with SYCustomPositionSource... tmp workaround using default SYPositioning https://jira.sygic.com/browse/CI-1088
        sygicMapsDefaultPositionProvider = SYPositioning()
        if speedLimitProviderEnabled {
            sygicMapsDefaultPositionProvider?.startUpdatingPosition()
        }

        if let lastLocation = lastKnownLocation {
            requestSpeedLimit(for: lastLocation)
        }
        SYNavigationManager.sharedNavigation()?.audioFeedbackDelegate = self
    }

    private func sdkPosition(from location: CLLocation) -> SYPosition {
        let coordinates = SYGeoCoordinate(latitude: location.coordinate.latitude,
                                          longitude: location.coordinate.longitude,
                                          altitude: location.altitude)
        let gps = SYPosition(coordinate: coordinates,
                             latitudeAccuracy: location.horizontalAccuracy,
                             longitudeAccuracy: location.horizontalAccuracy,
                             altitudeAccuracy: location.verticalAccuracy,
                             speed: location.speed * 3.6,
                             course: CGFloat(location.course),
                             timestamp: location.timestamp)
        return gps
    }

    private func sdkCource(from location: CLLocation) -> SYCourse {
        let courseAngle = SYAngle(location.course)
        let courseAccuracy: SYAccuracy
        courseAccuracy = SYAccuracy(location.courseAccuracy)
        let newCourse = SYCourse(course: courseAngle, courseAccuracy: courseAccuracy, timestamp: location.timestamp)
        return newCourse
    }
}

// MARK: SYNavigationDelegate

extension DrivingSpeedLimitManager: SYNavigationDelegate {
    public func navigation(_ observer: SYNavigationObserver, didUpdateSpeedLimit limit: SYSpeedLimitInfo?) {
        if let limit = limit {
            delegate?.drivingSpeedLimitManager(self, didUpdate: limit.speedLimit)
            //posluchac je VisionManager ktoreho zaujimaju tieto veci
            NotificationCenter.default.post(name: Notification.Name("MapSpeedLimitHasChanged"), object: NSNumber(floatLiteral: limit.speedLimit))
        }
    }
}

// MARK: SYNavigationAudioFeedbackDelegate

//MARK: - SYNavigationAudioFeedbackDelegate

extension DrivingSpeedLimitManager: SYNavigationAudioFeedbackDelegate {
    public func navigation(_ navigation: SYNavigationManager, shouldPlaySpeedLimitAudioFeedback speedLimit: SYSpeedLimitInfo) -> Bool {
        return false
    }

    public func navigation(_ navigation: SYNavigationManager, shouldPlayIncidentAudioFeedback incident: SYIncidentInfo) -> Bool {
        return false
    }

    public func navigation(_ navigation: SYNavigationManager, shouldPlayTrafficAudioFeedback traffic: SYTrafficInfo) -> Bool {
        return false
    }

    public func navigation(_ navigation: SYNavigationManager, shouldPlayBetterRouteAudioFeedback route: SYBetterRoute) -> Bool {
        return false
    }

    public func navigation(_ navigation: SYNavigationManager, shouldPlaySharpCurveAudioFeedback turn: SYSharpCurveInfo) -> Bool {
        return false
    }

    public func navigation(_ navigation: SYNavigationManager, shouldPlayRailwayAudioFeedback railway: SYRailwayCrossingInfo) -> Bool {
        return false
    }

    public func navigation(_ navigation: SYNavigationManager, shouldPlayInstructionAudioFeedback instruction: SYDirectionInfo) -> Bool {
        return false
    }
}
