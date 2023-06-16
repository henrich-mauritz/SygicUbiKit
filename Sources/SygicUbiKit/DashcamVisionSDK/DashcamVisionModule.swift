import Foundation
import Swinject

// MARK: - DashcamVisionModule

public class DashcamVisionModule {
    private static var defaultsInjected: Bool = false

    private init() {}

    /// Injects default module components and returns module entry view controller.
    /// - Returns: Module entry view controller
    public static func rootViewController(dataProvider: DashcamVisionProviderProtocol,
                                          drivingTheme: Bool = false) -> Dashcam {
        injectDefaults()
        return DashcamVision.dashcamControllerWithVision(dataProvider: dataProvider,
                                                         drivingTheme: drivingTheme)
    }

    /// Injects default components to InjectableType container required for module.
    /// Call this function before injecting your custom components for this module. No need to call, if you use RewardsModule.rootViewController() for initializing
    public static func injectDefaults() {
        guard !defaultsInjected else { return }
        let container = SYInjector.container
        container.register(DashcamControlsViewProtocol.self) { (_, dataProvider: DashcamProviderProtocol) -> DashcamControlsViewProtocol in
            let controlsView = DashcamVisionControlsView(provider: dataProvider)
            let overlayView = VisionOverlayView(frame: controlsView.bounds)
            overlayView.dashcamDistanceLabel = controlsView.overlayView.distanceLabel //weak reference
            controlsView.visionOverlayView = overlayView
            return controlsView
        }
        container.register(DashcamOnboardingSortable.self) { _ -> DashcamOnboardingSortable in
            DashcamVisionOnboarding()
        }.inObjectScope(.container)

        defaultsInjected = true
    }
}

public protocol DashcamVisionConfigurable {
    var signRecognitionEnabled: Bool { get }
    var tailgatingEnabled: Bool { get }
}
