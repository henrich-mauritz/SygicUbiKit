import Foundation

// MARK: - SpeedLimitSource

public enum SpeedLimitSource: Int {
    case vision
    case maps
}

// MARK: - DashcamVisionProviderProtocol

public protocol DashcamVisionProviderProtocol: DashcamProviderProtocol, VisionProviderProtocol {}
