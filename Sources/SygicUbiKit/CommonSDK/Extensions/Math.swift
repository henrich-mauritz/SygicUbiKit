import Foundation

public class Math {
    public static func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }

    public static func rad2Deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
}
