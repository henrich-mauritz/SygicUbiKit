import Foundation

public extension Double {
    static func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }

    static func rad2Deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
}
