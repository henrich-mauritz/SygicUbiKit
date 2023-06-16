import Foundation
import UIKit

// MARK: - VehicleProfileAddError

enum VehicleProfileAddEditError: String, LocalizedError {
    case noInternetConnection
    case allowedVehicleCountExceeded
    case vehicleWithThisNameAlreadyExists
    case vehicleNameTooLong
    case unknown

    init(with networkError: NetworkError) {
        switch networkError {
        case .noInternetConnection:
            self = .noInternetConnection
        case let .httpError(code, userInfo):
            if code == 422 {
                guard let userInfo = userInfo,
                      let data = userInfo["data"] as? [String: Any],
                      let reason = data["reason"] as? String else {
                          self = .unknown
                    return
                }
                self = VehicleProfileAddEditError(rawValue: reason) ?? .unknown
            } else {
                self = .unknown
            }
        default:
            self = .unknown
        }
    }

    var localizedTitle: String? {
        switch self {
        case .noInternetConnection:
            return "vehicleProfile.edit.errorNoInternet.title".localized
        case .allowedVehicleCountExceeded:
            return "vehicleProfile.edit.errorMaxReached.title".localized
        default:
            return "vehicleProfile.edit.errorGeneral.title".localized
        }
    }

    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "vehicleProfile.edit.errorNoInternet.subtitle".localized
        case .allowedVehicleCountExceeded:
            return "vehicleProfile.edit.errorMaxReached.subtitle".localized
        default:
            return "vehicleProfile.edit.errorGeneral.subtitle".localized
        }
    }

    var errorIcon: UIImage? {
        switch self {
        case .noInternetConnection:
            return UIImage(named: "warningXicon", in: .module, compatibleWith: nil)
        default:
            return UIImage(named: "errorXicon", in: .module, compatibleWith: nil)
        }
    }
}
