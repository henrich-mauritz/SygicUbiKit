import Foundation
import Driving

// MARK: - DrivingConfiguration

public protocol DrivingConfiguration where Self: AnyObject {
    var configuration: SygicDrivingConfiguration { get }
    var vehicleSettings: SygicVehicleSettings { get }
    var clientID: String { get }
    var appSecret: String { get }
    var automaticTripDetection: Bool { get }
    var eventsThresholds: DrivingEventsIntensityThresholds { get set }
    var minSpeedThreshold: Int { get }
    var minDurationSeconds: Double { get }
    var minDistanceM: Double { get }
    var animateDriveStateChange: Bool { get }
    var drivingVehicleProfileListTitle: String { get }
    var offSeasonsPerVehicle: [VehicleType: [Int]]? { set get }
    var drivingJWT: String { get }
}

public extension DrivingConfiguration {
    var drivingVehicleProfileListTitle: String { "" }
}

// MARK: - DrivingEventsIntensityThresholds

public protocol DrivingEventsIntensityThresholds {
    /// Threshold values for driving screen bottom gradients
    var acceleration: [Double] { get }
    /// Threshold values for driving screen top gradients
    var braking: [Double] { get }
    /// Threshold values for driving screen side gradients
    var cornering: [Double] { get }
    /// Speeding tolerance thresholds. Can be defined as tuple of speed and threshold.
    /// For example setting defined (70, 6) means, that current speed in interval between [speedLimit, dpeedLimit+6] above 70kmh will be presented just as warning.
    var speeding: [(speedAbove: Double, speedingThreshold: Double, severity: Int)] { get }
    /// Minimal speed for showing distraction events in driving screen
    var distractionMinSpeed: Double { get }
    /// Min duration in seconds
    var minDurationSeconds: Double { get }
    /// Min distance in Meters
    var minDistanceM: Double { get }
}

public extension DrivingEventsIntensityThresholds {
    var acceleration: [Double] { [0.3, 0.35, 0.4] }
    var braking: [Double] { [0.35, 0.4, 0.45] }
    var cornering: [Double] { [0.45, 0.5, 0.55] }
    var speeding: [(speedAbove: Double, speedingThreshold: Double, severity: Int)] { [
        (speedAbove: 0, speedingThreshold: 6, severity: 1),
        (speedAbove: 70, speedingThreshold: 6, severity: 1),
        (speedAbove: 100, speedingThreshold: 8, severity: 1),
    ] }
    var distractionMinSpeed: Double { 10 }
    var minDurationSeconds: Double { 120 }
    var minDistanceM: Double { 500 }
}

// MARK: Default values

public extension DrivingConfiguration {
    var minSpeedThreshold: Int { 7 }
    ///Animate color change on slider
    var animateDriveStateChange: Bool { false }
    var minDurationSeconds: Double { eventsThresholds.minDurationSeconds }
    var minDistanceM: Double { eventsThresholds.minDistanceM }
}

// MARK: - NetworkConfig

public struct NetworkConfig: Codable {
    public struct Container: Codable {
        var maxTotalVehicleCountPerUser: Int? = 10
        var vehicleConfigurations: [NetworkVehicleConfiguration]
    }

    public var data: Container

    public func thresholds(for vehicleType: VehicleType) -> DrivingEventsIntensityThresholds {
        let configuration = data.vehicleConfigurations.filter { $0.vehicleType == vehicleType }
        guard let configuration = configuration.first else { fatalError("No configuration for type, this is not allowed")}
        return configuration
    }

    public var vehicleConfigurations: [NetworkVehicleConfiguration] { data.vehicleConfigurations }
    public var maxTotalVehicleCountPerUser: Int? { data.maxTotalVehicleCountPerUser }

    public var offSeassons: [VehicleType: [Int]]? {
        var resultDic: [VehicleType: [Int]] = [:]
        data.vehicleConfigurations.forEach { resultDic[$0.vehicleType] = $0.offSeason }
        return resultDic
    }
}

// MARK: - VehicleType

public enum ConfigurationVehicleType: String, Codable {
    case unknown
    case car
    case motorcycle
    case camper

    public init(rawValue: String) {
        switch rawValue {
        case "car":
            self = .car
        case "motorcycle":
            self = .motorcycle
        case "camper":
            self = .camper
        default:
            self = .unknown
        }
    }
}

// MARK: - NetworkVehicleConfiguration

public struct NetworkVehicleConfiguration: Codable {
    public struct NetworTripValidationConditions: Codable {
        var minDurationSeconds: Double
        var minDistanceM: Double
    }

    public struct NetworkTripEventThresholds: Codable {
        var accelerationThresholds: [AccelerationThreshold]
        var brakingThresholds: [BrakingThreshold]
        var corneringThresholds: [CorneringThreshold]
        var distractionThresholds: [DistractionThreshold]
        var speedingThresholds: [SpeedingThreshold]
    }

    //MARK: - Server Thresholds Definitions

    public struct AccelerationThreshold: Codable {
        var accelerationValueThreshold: Double
        var severity: String
    }

    public struct BrakingThreshold: Codable {
        var brakingValueThreshold: Double
        var severity: String
    }

    public struct CorneringThreshold: Codable {
        var corneringValueThreshold: Double
        var severity: String
    }

    public struct DistractionThreshold: Codable {
        var speedKmHThreshold: Double
        var distractionValueThreshold: Double
        var severity: String
    }

    public struct SpeedingThreshold: Codable {
        var speedLimitKmH: Double
        var speedOverSpeedLimitKmhThreshold: Double
        var severity: String
    }

    public var vehicleType: VehicleType
    public var maxVehicleCountPerUser: Int?
    public var offSeason: [Int]
    public var tripValidationConditions: NetworTripValidationConditions
    public var tripEventThresholds: NetworkTripEventThresholds
}

// MARK: DrivingEventsIntensityThresholds

extension NetworkVehicleConfiguration: DrivingEventsIntensityThresholds {
    public var acceleration: [Double] {
        let mapped = tripEventThresholds.accelerationThresholds.map {Double($0.accelerationValueThreshold)}
        return mapped
    }

    public var braking: [Double] {
        let mapped = tripEventThresholds.brakingThresholds.map {Double($0.brakingValueThreshold)}
        return mapped
    }

    public var cornering: [Double] {
        let mapped = tripEventThresholds.corneringThresholds.map {Double($0.corneringValueThreshold)}
        return mapped
    }

    public var speeding: [(speedAbove: Double, speedingThreshold: Double, severity: Int)] {
        let mapped = tripEventThresholds.speedingThresholds.map {($0.speedLimitKmH, Double($0.speedOverSpeedLimitKmhThreshold), severityValue(from: $0.severity))}
        return mapped
    }

    public var distractionMinSpeed: Double {
        return tripEventThresholds.distractionThresholds.first?.speedKmHThreshold ?? 10
    }

    public var minDurationSeconds: Double { tripValidationConditions.minDurationSeconds }
    public var minDistanceM: Double { tripValidationConditions.minDistanceM }

    private func severityValue(from severity: String) -> Int {
        if severity == "level1" {
            return 1
        }
        if severity == "level2" {
            return 2
        }
        if severity == "level3" {
            return 3
        }
        return 0
    }
}

// MARK: - DefaultEventThresholds

public struct DefaultEventThresholds: DrivingEventsIntensityThresholds {
    public init() {}
}

// MARK: - ConfigThresholds

//MARK: - Configuration Thresholds

public struct ConfigThresholds: Codable {
    struct Container: Codable {
        var tripValidationConditions: ValidationConditions
        var tripEventThresholds: ConfigThresholds
    }

    struct ValidationConditions: Codable {
        var minDurationSeconds: Double
        var minDistanceM: Double
    }

    struct ConfigThresholds: Codable {
        var accelerationThresholds: [AccelerationThreshold]
        var brakingThresholds: [BrakingThreshold]
        var corneringThresholds: [CorneringThreshold]
        var distractionThresholds: [DistractionThreshold]
        var speedingThresholds: [SpeedingThreshold]
    }

    //MARK: - Server Thresholds Definitions

    struct AccelerationThreshold: Codable {
        var accelerationValueThreshold: Double
        var severity: String
    }

    struct BrakingThreshold: Codable {
        var brakingValueThreshold: Double
        var severity: String
    }

    struct CorneringThreshold: Codable {
        var corneringValueThreshold: Double
        var severity: String
    }

    struct DistractionThreshold: Codable {
        var speedKmHThreshold: Double
        var distractionValueThreshold: Double
        var severity: String
    }

    struct SpeedingThreshold: Codable {
        var speedLimitKmH: Double
        var speedOverSpeedLimitKmhThreshold: Double
        var severity: String
    }

    var data: Container
}
