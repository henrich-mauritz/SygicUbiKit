import Foundation
import UIKit

// MARK: - DashcamVisionDataProviderDelegate

public protocol DashcamVisionDataProviderDelegate: AnyObject {
    func dashcamVisionWantsShowApplicationSettings()
    func dashcamVisionAutomaticTripTrackingIsOn() -> Bool
    func dashcamVisionWantsShowMessage(message: String, for error: Error?)
    func didChangeTailgatingStatus(detected: Bool)
}

// MARK: - DashcamVisionDataProvider

open class DashcamVisionDataProvider: DashcamVisionProviderProtocol {
    public func dashcamDidAppear() {}
    public func dashcamWillDisappear() {}
    
    open var delegate: DashcamVisionDataProviderDelegate?
    open var data: DashcamDataProtocol = DashcamDrivingData()
    open var onLocationUpdate: ((DashcamDataProtocol) -> Void)?
    open var distanceUnit: DashcamDistanceUnits = .km
    open var inTrip: Bool {
        DrivingManager.shared.driving
    }
    open var automaticTripTracking: Bool {
        delegate?.dashcamVisionAutomaticTripTrackingIsOn() ?? false
    }

    public init() {
        VisionManager.shared.publicDelegate = self
    }

    open func dashcamRecording(_ recording: Bool) {
        if recording && drivingViewModel == nil {
            let drivingViewModel = DrivingViewModel()
            drivingViewModel.delegate = self
            self.drivingViewModel = drivingViewModel
        } else if !recording {
            drivingViewModel = nil
        }
        VisionManager.shared.visionEnabled = recording
        addEventDashcam(enabled: recording, hasVision: true)
    }

    open func showToast(message: String, icon: UIImage?, error: Error?) {
        if let error = error, ADASDebug.enabled {
            print(error)
        }
        delegate?.dashcamVisionWantsShowMessage(message: message, for: error)
    }

    open func setAudioSessionActive(_ active: Bool) {}

    open func showApplicationSettings() {
        delegate?.dashcamVisionWantsShowApplicationSettings()
    }

    private var drivingViewModel: DrivingViewModel?

    open func dashcamVisionHasUpdatedSpeedLimit(_ speedLimit: Double?, source: SpeedLimitSource) {
        guard source == .vision else { return }
        DrivingManager.shared.updateSpeedLimitFromVision(speedLimit)
    }

    open func dashcamVisionHasDetectedClosingCar(at timeDistance: TimeInterval?) {
        DrivingManager.shared.updateTailgatingTimeDistance(timeDistance)
        delegate?.didChangeTailgatingStatus(detected: timeDistance != nil)
    }

    open func addEventDashcam(enabled: Bool, hasVision: Bool) {
        DrivingManager.shared.addEventDashcam(enabled: enabled, hasVision: hasVision)
    }
    
}

// MARK: DrivingViewModelDelegate

extension DashcamVisionDataProvider: DrivingViewModelDelegate {
    public func viewModelUpdated(_ viewModel: DrivingViewModel) {
        let model = DrivingManager.shared
        var speed: Double?
        if viewModel.hasGPSSignal {
            speed = Double(model.currentSpeed)
        }
        let mapsSpeedLimit: Double? = VisionManager.shared.debugEnabled ? model.currentSpeedLimit : nil //dont provide data for default dashcam speedLimitView without debug
        let drivingData = DashcamDrivingData(speed: speed,
                                             speedLimit: mapsSpeedLimit,
                                             speedingColor: UIColor.speedingColor(with: viewModel.speedingIntensity),
                                             distanceDrivenKm: model.distanceTravelled / 1000,
                                             currentStreet: "",
                                             latitude: model.lastKnownLocation?.coordinate.latitude ?? 0,
                                             longitude: model.lastKnownLocation?.coordinate.longitude ?? 0)
        data = drivingData
        onLocationUpdate?(drivingData)
        
        //jur: preco model.currentSpeedLimit sa pridava tuna? skade ma model speedlimit? spatne by sme krmit nemali!
        //VisionManager.shared.processDrivingSpeedInfo(speed: speed, speedLimit: model.currentSpeedLimit)
        //Tu sa nam udeje cyklus..model sa zmeni lebo sa zmenil speed limit cez vision a nakrmi sa to nazad ako speed limit z mapy aj ked to nie je pravda.
        
        //this is fine, but should not be there at all.
        //VisionManager.shared.lastLocation = model.lastLocation
    }

    public func viewModel(_ viewModel: DrivingViewModel, tripIsRunning: Bool) {}
}

// MARK: - DashcamDrivingData

struct DashcamDrivingData: DashcamDataProtocol {
    var speed: Double?
    var speedLimit: Double?
    var speedingColor: UIColor?
    var distanceDrivenKm: Double?
    var currentStreet: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
}
