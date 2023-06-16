import Foundation
import Swinject

// MARK: - MonthlyStatsModule

public class MonthlyStatsModule {
    private static var defaultsInjected: Bool = false

    private init() {}

    /// Injects default module components and returns module entry view controller.
    /// - Returns: Module entry view controller
    public static func rootViewController() -> MonthlyStatsViewController {
        injectDefaults()
        return SYInjector.container.resolve(MonthlyStatsViewController.self)!
    }

    /// Injects default components to InjectableType container required for module.
    /// Call this function before injecting your custom components for this module. No need to call, if you use BadgesModule.rootViewController() for initializing
    public static func injectDefaults() {
        guard !defaultsInjected else { return }
        let container = SYInjector.container
        container.register(MonthlyStatsViewController.self, factory: { _ in MonthlyStatsViewController() })
        container.register(MonthlyStatsViewModelType.self) { (_: Resolver, currentMonthId: String) in
            MonthlyStatsViewModel(monthId: currentMonthId)
        }
        container.register(MonthlyStatsViewModelType.self) { _ in
            MonthlyStatsViewModel(monthId: nil)
        }
        container.register(MonthlyStatsViewType.self) { _ in MonthlyStatsView() }
        container.injectStatsRepo()
        defaultsInjected = true
    }
}

// MARK: - MonthlyStatsConfiguration

public protocol MonthlyStatsConfiguration {
    var minScoreThreshold: Int? { get }
    func textableURL(for event: EventType, comparision: ReportScoreMonthComparision) -> (fullText: String, url: URL, range: NSRange)?
}

public extension MonthlyStatsConfiguration {
    func textableURL(for: EventType, comparision: ReportScoreMonthComparision) -> (fullText: String, url: URL, range: NSRange)? {
        return nil
    }
}
