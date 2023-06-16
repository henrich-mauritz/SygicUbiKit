import Foundation
import Swinject

// MARK: - DiscountsModule

public class DiscountsModule {
    private static var defaultsInjected: Bool = false

    private init() {}

    /// Injects default module components and returns module entry view controller.
    /// - Returns: Module entry view controller
    public static func rootViewController() -> DiscountsViewController {
        injectDefaults()
        return SYInjector.container.resolve(DiscountsViewController.self)!
    }

    /// Injects default components to InjectableType container required for module.
    /// Call this function before injecting your custom components for this module. No need to call, if you use DiscountsModule.rootViewController() for initializing
    public static func injectDefaults() {
        guard !defaultsInjected else { return }
        let container = SYInjector.container
        container.register(DiscountsViewModelType.self, factory: { _ in DiscountsViewModel() })
        container.register(DiscountsViewProtocol.self, factory: { _ in DiscountsView() })
        container.register(DiscountCodesViewController.self, factory: { (_, vehicle: VehicleProfileType) in DiscountCodesViewController(with: DiscountCodesViewModel(with: vehicle))})
        container.register(DiscountProgressViewController.self, factory: {(_, vehicle: VehicleProfileType) in DiscountProgressViewController(with: vehicle)})
        container.register(DiscountHowToViewController.self) { (_, vehicle: VehicleProfileType) in DiscountHowToViewController(with: DiscountHowToViewModel(with: vehicle))}
        container.register(DiscountsViewController.self, factory: { _ in DiscountsViewController() })
        defaultsInjected = true
    }
}

public extension Notification.Name {
    static var discountMaxValueReached: Notification.Name { Notification.Name("DiscountsMaxValueReachedNotification") }
}

// MARK: - DiscountConfigurable

public protocol DiscountConfigurable {
    func fetchInsuranceURL(fromCode: String, completion: @escaping ((_ url: URL?) -> ()))
    
    var motorbikeSpecial: Bool { get }
}

extension DiscountConfigurable {
    var motorbikeSpecial: Bool {
        return false
    }
}
