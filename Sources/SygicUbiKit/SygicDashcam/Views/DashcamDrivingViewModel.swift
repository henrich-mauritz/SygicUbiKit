import Foundation
import UIKit

// MARK: - DashcamDrivingViewModelDelegate

public protocol DashcamDrivingViewModelDelegate: AnyObject {
    func dashcamViewModel(_ viewModel: DashcamDrivingViewModel, didUpdateData: DashcamDataProtocol)
}

// MARK: - DashcamDrivingViewModel

public final class DashcamDrivingViewModel {
    weak var delegate: DashcamDrivingViewModelDelegate?

    var speedLimit: String? {
        guard let limit = provider.data.speedLimit else { return nil }
        return String(format: "%.0f", limit)
    }

    var speed: String? {
        guard let speed = provider.data.speed else { return "-"}
        return String(format: "%.0f", speed)
    }

    var speedUnits: String {
        if provider.distanceUnit == .km {
            return "km/h"
        } else {
            return "mph"
        }
    }

    var speedingColor: UIColor {
        provider.data.speedingColor ?? .foregroundDriving
    }

    var distanceWithUnits: String? {
        guard let distance = distance else { return nil }
        return "\(distance) \(distanceUnits)"
    }

    var distance: String? {
        //return "12" //uncomment when simulating
        guard let distance = provider.data.distanceDrivenKm, distance > 0 else { return nil }
        if distance < 10 {
            return String(format: "%.1f", distance)
        } else {
            return String(format: "%.0f", distance)
        }
    }

    var distanceUnits: String {
        if provider.distanceUnit == .km {
            return "km"
        } else {
            return "mi"
        }
    }

    var hasDataToPresent: Bool {
        //return true //uncomment when simulating
        let data = provider.data
        return data.latitude != 0 || data.longitude != 0 || data.speedLimit != nil || data.speed != nil
    }

    public var driving: Bool { provider.inTrip }

    private var provider: DashcamProviderProtocol
    private(set) var speedFormatted: String = ""
    private(set) var locationFormatted: String = ""

    init(provider: DashcamProviderProtocol) {
        self.provider = provider

        self.provider.onLocationUpdate = { [weak self] data in
            self?.updateLocationInfo(with: data)
        }
    }

    private func updateLocationInfo(with data: DashcamDataProtocol) {
        delegate?.dashcamViewModel(self, didUpdateData: data)
    }
}
