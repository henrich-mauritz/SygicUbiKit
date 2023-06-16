import UIKit

// MARK: - DashcamProviderProtocol

public protocol DashcamProviderProtocol {
    var data: DashcamDataProtocol { get }
    var onLocationUpdate: ((DashcamDataProtocol) -> Void)? { get set }
    var distanceUnit: DashcamDistanceUnits { get }
    var automaticTripTracking: Bool { get }
    var inTrip: Bool { get }
    
    func dashcamRecording(_ recording: Bool)
    func showToast(message: String, icon: UIImage?, error: Error?)
    func setAudioSessionActive(_ active: Bool)
    func showApplicationSettings()
    func dashcamDidAppear()
    func dashcamWillDisappear()
    func addEventDashcam(enabled: Bool, hasVision: Bool)
}

// MARK: - DashcamDataProtocol

public protocol DashcamDataProtocol {
    var speed: Double? { get }
    var speedLimit: Double? { get }
    var speedingColor: UIColor? { get }
    var distanceDrivenKm: Double? { get }
    var currentStreet: String { get }
    var latitude: Double { get }
    var longitude: Double { get }
}
