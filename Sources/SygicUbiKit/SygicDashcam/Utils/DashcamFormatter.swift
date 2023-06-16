import Foundation

// MARK: - DashcamDistanceUnits

public enum DashcamDistanceUnits: String {
    case km
    case milesFeet
    case milesYards

    var speedTitle: String {
        switch self {
        case .km: return "dashcam.velocityMetric".localized
        case .milesFeet, .milesYards: return "dashcam.velocityImperial".localized
        }
    }
}

// MARK: - DashcamFormatter

enum DashcamFormatter {
    static func format(_ distance: Double, from fromUnit: DashcamDistanceUnits, to toUnit: DashcamDistanceUnits) -> Double {
        let kmToMile = 0.62137119
        let mileToKm = 1.609344

        var constant = 1.0

        if fromUnit == .km && (toUnit == .milesYards || toUnit == .milesFeet) {
            constant = kmToMile
        } else if (fromUnit == .milesYards || fromUnit == .milesFeet) && toUnit == .km {
            constant = mileToKm
        }

        return distance * constant
    }
}
