import Foundation
import Swinject

// MARK: - MultipleDrivingScreenModule

public class MultipleDrivingScreenModule {
    private static var defaultsInjected: Bool = false

    private init() {}

    /// Injects default module components and returns module entry view controller.
    /// - Returns: Module entry view controller
    public static func rootViewController() -> MultipleDrivingScreenViewController {
        injectDefaults()
        return SYInjector.container.resolve(MultipleDrivingScreenViewController.self)!
    }

    /// Injects default components to InjectableType container required for module.
    /// Call this function before injecting your custom components for this module. No need to call, if you use BadgesModule.rootViewController() for initializing
    public static func injectDefaults() {
        guard !defaultsInjected else { return }
        defaultsInjected = true
    }
}

public extension Notification.Name {
    static var didAddedControllersToAlternativeScreen: Notification.Name {Notification.Name(rawValue: "didAddedControllerToAlternativeScreen") }
}
