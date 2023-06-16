import Foundation

public extension NumberFormatter {
    func distanceTraveledFormatted(value: Double) -> String {
        numberStyle = .decimal
        minimumIntegerDigits = 1
        minimumFractionDigits = 0
        maximumFractionDigits = value < 10 ? 1 : 0
        roundingMode = .floor
        return string(for: value) ?? "0"
    }
}

// MARK: - Format

public class Format {
    public static func scoreFormatted(value: Double) -> String {
        // last updated by https://jira.sygic.com/browse/TRIG-974
//        if (value < 99) {
//            return "\(Int(round(value)))"
//        } else {
//            return "\(Int(value))"
//        }
        return "\(Int(value))"
    }
}
