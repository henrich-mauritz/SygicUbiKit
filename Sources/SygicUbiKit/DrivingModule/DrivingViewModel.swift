import UIKit
import Driving

// MARK: - DrivingViewModelDelegate

public protocol DrivingViewModelDelegate: AnyObject {
    func viewModelUpdated(_ viewModel: DrivingViewModel)
    func viewModel(_ viewModel: DrivingViewModel, tripIsRunning: Bool)
}

// MARK: - DrivingViewModel

public class DrivingViewModel {
    //MARK: - Properties

    public weak var delegate: DrivingViewModelDelegate?

    public var drivingLibInitialized: Bool {
        drivingManager.drivingLibInitialized
    }

    public var distanceTravelled: String {
        let newValue = drivingManager.distanceTravelled / 1000.0
        return NumberFormatter().distanceTraveledFormatted(value: newValue)
    }

    public var distance: Double {
        drivingManager.distanceTravelled
    }

    public var currentSpeed: String {
        if !hasGPSSignal {
            return "-"
        }
        return "\(drivingManager.currentSpeed)"
    }

    public var hasGPSSignal: Bool {
        return drivingManager.hasGPSSignal
    }

    public var canStartOrStopTrip: Bool {
        drivingManager.currentSpeed < 30 && drivingLibInitialized
    }

    public var driving: Bool {
        drivingManager.driving
    }

    public var speeding: Bool {
        guard let speedLimit = drivingManager.currentSpeedLimit else { return false }
        return drivingManager.currentSpeed > Int(speedLimit)
    }

    public var distractionEvent: Bool {
        guard let currentVehicle = self.currentVehicle else {
            return inDistraction()
        }
        guard currentVehicle.vehicleType != .motorcycle else { return false }
        return inDistraction()
    }

    private func inDistraction() -> Bool {
        guard driving && distractionEventEnabled else { return false }
        let distraction = drivingManager.events.contains(where: { $0.type == .distraction })
        return distraction
    }

    public var currentSpeedLimit: String? {
        guard let speedLimit = drivingManager.currentSpeedLimit else { return nil }
        return String(format: "%.0f", speedLimit)
    }

    public var lastEventTitle: String {
        guard driving else { return "driving.statusGetReady".localized }

        if !hasGPSSignal {
            return "driving.statusNoGPS".localized
        }

        let lastEvent = drivingManager.events.last(where: { $0.intensity >= 0 })
        if drivingManager.detectorState == .disoriented, lastEvent?.event.eventType != .distraction {
            return "driving.statusCalibrating".localized
        }
        var title = isOver100meters() ? "\(distanceTravelled) km" : "driving.statusDriving".localized
        guard let event = lastEvent, event.intensity > 0 else { return title }
        switch event.event.eventType {
        case .acceleration:
            title = "driving.statusAccelerating".localized
        case .braking:
            title = "driving.statusBreaking".localized
        case .cornering:
            title = "driving.statusCornering".localized
        case .distraction:
            guard distractionEventEnabled else { break }
            title = "driving.statusDistraction".localized
        case .end:
            title = "driving.statusGetReady".localized
        default:
            break
        }
        if ADASDebug.enabled {
            return "\(title) \(String(format: "%.2f", event.event.eventCurrentSize))"
        } else {
            return title
        }
    }

    public var speedingIntensity: Int {
        guard hasGPSSignal else {
            return 0
        }
        guard speeding, let speedLimit = drivingManager.currentSpeedLimit else { return 0 }
        let currentSpeed: Double = Double(drivingManager.currentSpeed)
        guard currentSpeed > speedLimit else { return 0 }
        var threshold: Double = 0
        if let thresholds = drivingManager.configuration?.eventsThresholds.speeding.filter({ $0.severity == 1 }) {
            for item in thresholds.sorted(by: { $0.speedAbove < $1.speedAbove }) {
                guard currentSpeed >= item.speedAbove else { break }
                threshold = item.speedingThreshold
            }
        }
        if currentSpeed >= speedLimit + threshold {
            return 2
        } else {
            return 1
        }
    }

    public var shouldPlayAnimations: Bool { drivingManager.driving && tripSummaryViewModel == nil }

    public var eventToPlay: TripEvent? {
        let playableEvents = drivingManager.events.filter { $0.intensity >= 1 && $0.animations != nil }
        return playableEvents.first
    }

    public var brakingIntensity: Int {
        var intensity = 0
        if distractionEvent {
            return 3
        }
        if let gradientEvent = drivingManager.events.last(where: { $0.type == .braking }) {
            intensity = gradientEvent.intensity
        }
        return intensity
    }

    public var accelerationIntensity: Int {
        var intensity = 0
        if distractionEvent {
            return 3
        }
        if let gradientEvent = drivingManager.events.last(where: { $0.type == .acceleration }) {
            intensity = gradientEvent.intensity
        }
        return intensity
    }

    public var corneringLeftIntensity: Int {
        var intensity = 0
        if distractionEvent {
            return 3
        }
        if let gradientEvent = drivingManager.events.last(where: { $0.type == .cornering }), gradientEvent.event.eventCurrentSize < 0 {
            intensity = gradientEvent.intensity
        }
        return intensity
    }

    public var corneringRightIntensity: Int {
        var intensity = 0
        if distractionEvent {
            return 3
        }
        if let gradientEvent = drivingManager.events.last(where: { $0.type == .cornering }), gradientEvent.event.eventCurrentSize > 0 {
            intensity = gradientEvent.intensity
        }
        return intensity
    }

    public var currentVehicle: VehicleProfileType? {
        return VehicleProfileModule.currentDrivingVehicle()
    }

    public var hasMoreThanOneVehicle: Bool {
        return VehicleProfileModule.hasMoreThanOneActiveVehcile()
    }

    var debugSpeed: String { "\(drivingManager.currentSpeed)" }
    var debugAccuracy: String { "\(drivingManager.currentAccuracy)" }

    private var distractionEventEnabled: Bool {
        guard let currentVehicle = currentVehicle else {
            guard let distractionMinSpeed = drivingManager.configuration?.eventsThresholds.distractionMinSpeed else { return false }
            return drivingManager.currentSpeed >= Int(distractionMinSpeed)
        }

        guard currentVehicle.vehicleType != .motorcycle else {
            return false
        }

        guard let distractionMinSpeed = drivingManager.configuration?.eventsThresholds.distractionMinSpeed else { return false }
        return drivingManager.currentSpeed >= Int(distractionMinSpeed)
    }

    private var tripSummaryViewModel: DrivingResultViewModel?
    private var tripSummaryErrorViewModel: DrivingResultViewModel?
    private var drivingManager: DrivingManager

    //MARK: - LifeCycle

    public required init(addToMultiCastDelegate: Bool = true) {
        drivingManager = DrivingManager.shared
        if addToMultiCastDelegate {
            drivingManager.add(delegate: self)
        }
        drivingManager.trackPerfectLocation = true
        if driving {
            UIApplication.shared.isIdleTimerDisabled = true
        } else {
            drivingManager.reset()
        }
        if ReachabilityManager.shared.status != .unreachable {
            DrivingSpeedLimitManager.shared.initializeLibraryIfNeeded {
                
            }
        }
    }

    deinit {
        print(":::  DEINIT DRIVING VIEWMODEL :::")
        drivingManager.trackPerfectLocation = false
        drivingManager.remove(delegate: self)
        UIApplication.shared.isIdleTimerDisabled = false
    }

    public func getResultViewModel() -> DrivingResultViewModel? {
        if tripSummaryViewModel != nil {
            return tripSummaryViewModel
        }
        return tripSummaryErrorViewModel
    }

    public func startTrip() {
        drivingManager.startTrip()
        delegate?.viewModelUpdated(self)
    }

    public func stopTrip() {
        drivingManager.stopTrip()
        delegate?.viewModelUpdated(self)
    }

    private func isOver100meters() -> Bool {
        return drivingManager.distanceTravelled >= 100
    }

    public func isInOffSeasson(for vehicleType: VehicleType) -> Bool {
        guard let offSeassonsData = DrivingManager.shared.configuration?.offSeasonsPerVehicle else {
            return false
        }
        let currentMonth = Date().currentMonthNumber
        if let _ = offSeassonsData[vehicleType]?.first(where: { $0 == currentMonth}) {
            return true
        }
        return false
    }
}

// MARK: DrivingModelDelegate

extension DrivingViewModel: DrivingModelDelegate {
    public func drivingManager(_ drivingManager: DrivingManager, didEncounter error: Error) {
        delegate?.viewModelUpdated(self)
        if ADASDebug.enabled {
            if case let DrivingError.dbLibInit(initError) = error {
                ToastMessage.shared.present(message: ToastViewModel(title: initError.localizedDescription), completion: nil)
            }
        }
    }

    public func drivingDataUpdated() {
        delegate?.viewModelUpdated(self)
    }

    public func drivingManagerDidStartTrip(_ drivingManager: DrivingManager) {
        UIApplication.shared.isIdleTimerDisabled = true
        delegate?.viewModel(self, tripIsRunning: true)
    }

    public func drivingManager(_ drivingManager: DrivingManager, didEndTrip trip: SygicDrivingTrip?) {
        UIApplication.shared.isIdleTimerDisabled = false
        tripSummaryViewModel = DrivingResultViewModel(tripData: trip)
        delegate?.viewModel(self, tripIsRunning: false)
    }

    public func drivingDataTripEnded(_ drivingManager: DrivingManager, tripId: String?, success: Bool, errorStatus: SygicTripUploadError) {}

    public func driving(_ drivingManager: DrivingManager, tripDiscartedWith reason: SygicTripDiscartedReason) {
        UIApplication.shared.isIdleTimerDisabled = false
        var summaryErrorState: StatusState = .error(reason: .invalidDurationTooShort)
        if reason == .traveledDistanceTooShort {
            summaryErrorState = .error(reason: .invalidDistanceTooShort)
        }
        if tripSummaryViewModel != nil {
            tripSummaryViewModel?.update(tripData: nil, state: summaryErrorState)
        } else {
            tripSummaryErrorViewModel = DrivingResultViewModel(tripData: nil, state: summaryErrorState)
        }
        delegate?.viewModel(self, tripIsRunning: false)
    }
}

// MARK: - Events intensities

extension TripEvent {
    public var intensity: Int {
        guard let thresholds = DrivingManager.shared.configuration?.eventsThresholds else { return 0 }
        var value: Int = 0
        let eventSize = abs(event.eventCurrentSize)
        switch type {
        case .acceleration:
            value = intensity(of: eventSize, from: thresholds.acceleration)
        case .braking:
            value = intensity(of: eventSize, from: thresholds.braking)
        case .cornering:
            value = intensity(of: eventSize, from: thresholds.cornering)
        case .distraction:
            return 3
        default:
            break
        }
        return value
    }

    private func intensity(of value: Double, from thresholds: [Double]) -> Int {
        var intensity = 0
        thresholds.enumerated().forEach { index, threshold in
            if value > threshold {
                intensity = index + 1
            } else {
                if value > thresholds.last ?? 0 {
                    intensity = thresholds.count + 1
                }
            }
        }
        return intensity
    }
}

public extension UIColor {
    static func speedingColor(with speedingIntensity: Int) -> UIColor {
        switch speedingIntensity {
        case 0:
            return .foregroundDriving
        case 1:
            return .negativeSecondary
        default:
            return .negativePrimary
        }
    }
}
