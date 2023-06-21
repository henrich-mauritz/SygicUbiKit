import Foundation

// MARK: - ADASDebug

public class ADASDebug {
    public static var enabled: Bool {
//        guard let plistVar = Bundle.main.infoDictionary?["DEBUG_LOGS"] as? String,
//              let boolValue = plistVar.bool else { return false }
//        return boolValue
        return false // TODO
    }

    public static var visionDebugEnabled: Bool {
        guard let plistVar = Bundle.main.infoDictionary?["VISION_DEBUG"] as? String,
              let boolValue = plistVar.bool else { return false }
        return boolValue
    }
}

extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return nil
        }
    }
}
