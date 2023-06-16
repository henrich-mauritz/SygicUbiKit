import Foundation
import Swinject

// MARK: - BadgesModule

public class BadgesModule {
    private static var defaultsInjected: Bool = false
    public static let kLastChangeDateKey: String = "BadgesModuleLastChangeDateKey"

    private init() {}

    /// Injects default module components and returns module entry view controller.
    /// - Returns: Module entry view controller
    public static func rootViewController() -> BadgesListViewController {
        injectDefaults()
        return SYInjector.container.resolve(BadgesListViewController.self)!
    }

    /// Injects default components to InjectableType container required for module.
    /// Call this function before injecting your custom components for this module. No need to call, if you use BadgesModule.rootViewController() for initializing
    public static func injectDefaults() {
        guard !defaultsInjected else { return }
        let container = SYInjector.container
        container.register(BadgesListViewController.self, factory: { _ in BadgesListViewController() })
        container.register(BadgesListViewModelType.self) { _ in BadgesListViewModel() }
        container.register(BadgeViewModelDetailType.self, factory: { _, badgeId in BadgeDetailViewModel(id: badgeId)})
        container.register(BadgesListViewType.self) { _ in BadgesListView() }
        container.injectBadgeRepo()
        defaultsInjected = true
    }

    public static func checkForNewBadges(completion: @escaping (Bool) -> ()) {
        let container = SYInjector.container
        let repo = container.resolveBadgesRepo()
        repo.checkForNewBadges { result in
            switch result {
            case .failure(_):
                completion(false)
            case let .success(data):
                guard let data = data else {
                    completion(false)
                    return
                }
                completion(data.isAnyNewBadgeLevelUnlocked)
            }
        }
    }
}
