import Foundation
import UIKit

// MARK: - DashcamOnboardingOrderType

public enum DashcamOnboardingOrderType: Equatable {
    case permissions
    case informative //not really a permission but could be initial screen in the onboarding process, also called blackBox
    case tripDetection
    case custom(controller: DashcamOnboardable)

    public static func == (lhs: DashcamOnboardingOrderType, rhs: DashcamOnboardingOrderType) -> Bool {
        switch (lhs, rhs) {
        case let (.custom(lhsController), .custom(rhsController)):
            return lhsController == rhsController
        case (.permissions, .permissions):
            return true
        case (.informative, .informative):
            return true
        case (.tripDetection, .tripDetection):
            return true
        default:
            return false
        }
    }
}

// MARK: - DashboardOnboardingPermissionType

public enum DashboardOnboardingPermissionType {
    case cameraPermission
    case libraryPermission
}

public typealias DashcamOnboardingSortable = DashcamOnboardingStepsSortable & DashcamOnboardingPermissionConfigurable

// MARK: - DashcamOnboardingStepsSortable

public protocol DashcamOnboardingStepsSortable {
    var orderedSteps: [DashcamOnboardingOrderType] { get }
    func controllerFor(step: DashcamOnboardingOrderType) -> DashcamOnboardable
    /// Each controller in the onboardding has a UIImageview that can be set to some value
    /// - Parameter type: type of the current step
    func defaultBackgroundImageFor(type: DashcamOnboardingOrderType) -> UIImage?
    func nextType(from type: DashcamOnboardingOrderType) -> DashcamOnboardingOrderType?
}

public extension DashcamOnboardingStepsSortable {
    func nextType(from type: DashcamOnboardingOrderType) -> DashcamOnboardingOrderType? {
        let steps = orderedSteps
        let index = steps.firstIndex { current -> Bool in
            type == current
        }
        guard let i = index, i + 1 < steps.count else {
            return nil
        }
        return steps[i + 1]
    }
}

// MARK: - DashcamOnboardingPermissionConfigurable

public protocol DashcamOnboardingPermissionConfigurable {
    /// For each permission type, the controller could change the background image in case the app wants
    /// - Parameter permissionType: permission type
    func backgroundImageFor(permissionType: DashboardOnboardingPermissionType) -> UIImage?
}

// MARK: - DashcamOnboardable

public protocol DashcamOnboardable where Self: UIViewController {
    var delegate: DashcamOnboardingDelegate? { get set }
}
