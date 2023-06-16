import Foundation
import UIKit

// MARK: - DashcamOnboardingDefaults

open class DashcamOnboardingDefaults: DashcamOnboardingSortable {
    public init() {}

    open var orderedSteps: [DashcamOnboardingOrderType] {
        return [.informative, .permissions, .tripDetection]
    }

    public func controllerFor(step: DashcamOnboardingOrderType) -> DashcamOnboardable {
        if step == .informative && !UserDefaults.dashcamOnboardingSeen {
            return DashcamOnboardingBlackboxViewController()
        } else {
            switch step {
            case .informative, .permissions:
                let v = DashcamOnboardingPermissionsViewController()
                return v
            case .tripDetection:
                let v = DashcamOnboardingTripDetectionViewController()
                return v
            case let .custom(controller):
                return controller
            }
        }
    }

    public func defaultBackgroundImageFor(type: DashcamOnboardingOrderType) -> UIImage? {
        var image: UIImage?
        switch type {
        case .tripDetection:
            image = UIImage(named: "dashcam_onboarding_atd", in: .module, compatibleWith: nil)
        case .informative:
            image = UIImage(named: "dashcam_onboarding_blackbox", in: .module, compatibleWith: nil)
        default:
            image = UIImage(named: "dashcam_onboarding_permissions", in: .module, compatibleWith: nil)
        }

        if DashcamColorManager.shared.isDark {
            let traitCollection = UITraitCollection(userInterfaceStyle: .dark)
            image = image?.withConfiguration(traitCollection.imageConfiguration)
        }

        return image
    }
}

public extension DashcamOnboardingDefaults {
    func backgroundImageFor(permissionType: DashboardOnboardingPermissionType) -> UIImage? {
        var image = UIImage(named: "dashcam_onboarding_permissions", in: .module, compatibleWith: nil)
        if DashcamColorManager.shared.isDark {
            let traitCollection = UITraitCollection(userInterfaceStyle: .dark)
            image = image?.withConfiguration(traitCollection.imageConfiguration)
        }
        return image
    }
}
