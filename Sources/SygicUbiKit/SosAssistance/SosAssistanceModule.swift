import Foundation
import Swinject

// MARK: - SosAssistanceModule

public class SosAssistanceModule {
    private static var defaultsInjected: Bool = false

    private init() {}

    /// Injects default module components and returns module entry view controller.
    /// - Returns: Module entry view controller
    public static func rootViewController(with model: SosAssistanceModel) -> SosAssistanceViewController {
        SYInjector.container.register(SosAssistanceModel.self, factory: { _ in model })
        injectDefaults(model: model)
        return SYInjector.container.resolve(SosAssistanceViewController.self)!
    }

    /// Injects default components to InjectableType container required for module.
    /// Call this function before injecting your custom components for this module. No need to call, if you use SosAssistanceModule.rootViewController() for initializing
    public static func injectDefaults(model: SosAssistanceModel) {
        guard !defaultsInjected else { return }
        let container = SYInjector.container
        container.register(SosAssistanceViewController.self, factory: { _ in SosAssistanceViewController() })
    
        container.register(SosAssistanceViewModelProtocol.self, factory: { r in
            SosAssistanceViewModel(with: model)
        })
        container.register(SosAssistanceViewProtocol.self, factory: { _ in SosAssistanceView() })
        defaultsInjected = true
    }
}
