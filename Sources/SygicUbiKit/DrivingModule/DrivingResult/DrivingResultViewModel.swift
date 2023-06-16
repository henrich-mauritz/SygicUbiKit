import Foundation
import UIKit
import Driving

// MARK: - StatusState

public enum StatusState: Equatable {
    case loading
    case tripScored(score: Double)
    case timeOut
    case offline
    case error(reason: SygicTripUploadError)
}

// MARK: - DrivingResultViewModelDelegate

public protocol DrivingResultViewModelDelegate where Self: UIViewController {
    func viewModelUpdated(_ viewModel: DrivingResultViewModel)
}

// MARK: - DrivingResultViewModel

public class DrivingResultViewModel {
    public weak var delegate: DrivingResultViewModelDelegate? {
        didSet {
            if viewState != .loading && tripData == nil {
                delegate?.viewModelUpdated(self)
            }
        }
    }

    public private(set) var viewState: StatusState = .loading {
        didSet {
            delegate?.viewModelUpdated(self)
        }
    }

    public var tripId: String?

    public var tripScore: Double?

    public var duration: String {
        guard let tripData = tripData else { return "" }
        let duration = tripData.tripEndDate.timeIntervalSince(tripData.tripStartDate)
        let hours = Int(duration / (60 * 60))
        let minuts = Int(duration / 60) % 60
        return "\(hours) h \(minuts) min"
    }

    public var distanceTravelled: String {
        guard let tripData = tripData else { return "" }
        let newValue = tripData.tripTraveledDistance / 1000.0
        return NumberFormatter().distanceTraveledFormatted(value: newValue) + " km"
    }

    private var tripData: SygicDrivingTrip?

    @objc private let timeout: TimeInterval = 7
    private let timeout2: TimeInterval = 3
    private var timer: Timer?
    private var timer2: Timer?
    static let durationThreshold: TimeInterval = DrivingManager.shared.configuration?.minDurationSeconds ?? 120
    static let distanceThreshold: Double = DrivingManager.shared.configuration?.minDistanceM ?? 400

    init(tripData: SygicDrivingTrip?, state: StatusState = .loading) {
        self.tripData = tripData
        viewState = state
        if state == .loading {
            DrivingManager.shared.multicastDelegate.add(delegate: self)
            if ReachabilityManager.shared.status == .unreachable {
                viewState = .offline
            } else {
                timer = Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(tripDetailRequest), userInfo: nil, repeats: false)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification(_:)), name: .tripSummaryNotification, object: nil)
            NotificationCenter.default.post(name: .drivingWaitingForTripScore, object: self)
        }
    }

    /// To be called only when there is error
    /// - Parameters:
    ///   - tripData: data of the trip
    ///   - state: state, probably some errro
    func update(tripData: SygicDrivingTrip?, state: StatusState) {
        timer?.invalidate()
        self.tripData = tripData
        viewState = state
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        DrivingManager.shared.multicastDelegate.remove(delegate: self)
    }

    func waitingForTripScoreFinished() {
        timer?.invalidate()
        timer2?.invalidate()
        NotificationCenter.default.post(name: .drivingWaitingForTripScore, object: nil)
    }

    @objc private func receiveNotification(_ notification: NSNotification) {
        timer?.invalidate()
        guard let dict = notification.userInfo as NSDictionary?,
            let tripId = dict["tripId"] as? String,
            let score = dict["tripScore"] as? Double,
            let stateWithScore = getResultScreenViewStatus(pushTripId: tripId, pushScore: score) else { return }
        viewState = stateWithScore
    }

    public func getResultScreenViewStatus(pushTripId: String, pushScore: Double) -> StatusState? {
        guard let tripId = tripId, tripId == pushTripId else { return nil }
        return .tripScored(score: pushScore)
    }

    private func getTripScore(_ tripId: String, completion: @escaping (Result<Double, Error>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterDrivingModule.triplogTripDetail(tripId)) { (result: Result<TriplogDetailData?, Error>) in
            if self.viewState == .loading {
                if ReachabilityManager.shared.status == .unreachable {
                    self.viewState = .offline
                } else {
                    self.timer2 = Timer.scheduledTimer(timeInterval: self.timeout2, target: self, selector: #selector(self.timeOut), userInfo: nil, repeats: false)
                }
            }
            switch result {
            case .success(let data):
                guard let tripData = data else {
                    completion(.failure(NetworkError.unknown))
                    return
                }
                completion(.success(tripData.data.totalScore))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @objc private func timeOut() {
        if case .loading = viewState {
            viewState = .timeOut
        }
    }
    
    @objc private func tripDetailRequest() {
        NotificationCenter.default.removeObserver(self, name: .tripSummaryNotification, object: nil)
        guard let id = tripId else {
            return
        }
        getTripScore(id, completion: { [weak self] result in
            guard let self = self else { return }
            guard self.viewState == .loading else { return }
            switch result {
            case let .success(score):
                if let stateWithScore = self.getResultScreenViewStatus(pushTripId: id, pushScore: score) {
                    self.viewState = stateWithScore
                }
            case let .failure(error):
                print("Networking error: \(error)")
                self.viewState = .error(reason: SygicTripUploadError.unknown)
            }
        })
    }
    
}

// MARK: DrivingModelDelegate

extension DrivingResultViewModel: DrivingModelDelegate {
    public func drivingManager(_ drivingManager: DrivingManager, didEncounter error: Error) {}
    public func drivingDataUpdated() {}
    public func drivingManager(_ drivingManager: DrivingManager, didStartTrip trip: SygicDrivingTrip) {}
    public func drivingManager(_ drivingManager: DrivingManager, didEndTrip trip: SygicDrivingTrip?) {
        tripData = trip
        delegate?.viewModelUpdated(self)
    }

    public func drivingDataTripEnded(_ drivingManager: DrivingManager, tripId: String?, success: Bool, errorStatus: SygicTripUploadError) {
        if success, let id = tripId {
            self.tripId = id
        } else {
            viewState = .error(reason: errorStatus)
        }
        delegate?.viewModelUpdated(self)
    }
}
