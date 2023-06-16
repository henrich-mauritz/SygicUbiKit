import Foundation
import Swinject

public class DashcamModule {
    private static var defaultsInjected: Bool = false

    //MARK: - Lifecycle

    private init() {}

    /// Configure whole Dashcam module, this shall be called first from app side in order
    public static func injectDefaults() {
        guard !defaultsInjected else { return }
        injectComponents()
    }

    private static func injectComponents() {
        let container = SYInjector.container
        if container.resolve(DashcamOnboardingSortable.self) == nil {
            container.register(DashcamOnboardingSortable.self) { _ -> DashcamOnboardingSortable in
                DashcamOnboardingDefaults()
            }.inObjectScope(.container)
        }
        defaultsInjected = true
    }
}
