import Foundation
import UIKit
import Swinject

// MARK: - RewardsModule

public class RewardsModule {
    public struct UserDefaultKeys {
        public static var awardedRewardKey: String = "userDefaultsAwardedRewardKey"
        static var lastChangeDateKey: String = "userDefaultsRewardsLastChangeDateKey"
    }

    private static var defaultsInjected: Bool = false

    private init() {}

    /// Injects default module components and returns module entry view controller.
    /// - Returns: Module entry view controller
    public static func rootViewController() -> RewardsViewController {
        injectDefaults()
        return SYInjector.container.resolve(RewardsViewController.self)!
    }

    /// Injects default components to InjectableType container required for module.
    /// Call this function before injecting your custom components for this module. No need to call, if you use RewardsModule.rootViewController() for initializing
    public static func injectDefaults() {
        guard !defaultsInjected else { return }
        let container = SYInjector.container
        container.register(RewardsViewController.self, factory: { r in RewardsViewController(with: r.resolve(RewardsListViewModelProtocol.self)) })
        container.register(RewardsListViewModelProtocol.self, factory: { _ in RewardsListViewModel() })
        container.register(RewardsListViewProtocol.self, factory: { _ in RewardsTableView() })
        container.register(RewardCellProtocol.self, factory: { _ in RewardCell() })
        container.register(RewardDetailViewController.self, factory: { _ in RewardDetailViewController() })
        container.register(RewardDetailViewProtocol.self, factory: { _ in RewardDetailView() })

        if let _ = container.resolve(RewardsStyleConfigurable.self, name: RewardsResolversNames.styleResolver) {
            // do nothing
        } else {
            container.register(RewardsStyleConfigurable.self, name: RewardsResolversNames.styleResolver) { _ in RewardsStyling() }
        }
        defaultsInjected = true
    }

    /// checks against api whether there is a new contest gained
    /// - Parameter completion: upon network completion call, this completion will contain the NetworkWhatsNewRewardsData with the relative information
    /// - Returns: void
    public static func checkForNewRewards(completion: @escaping (NetworkWhatsNewRewardsData?) -> ()) {
        let container = SYInjector.container
        let repo = container.resolveRewardsRepo()
        repo.checkForNewContents(completion: { result in
            switch result {
            case .failure(_):
                completion(nil)
            case let .success(data):
                guard let data = data else {
                    completion(nil)
                    return
                }
                completion(data)
            }
        })
    }
}

// MARK: - RewardsResolversNames

public struct RewardsResolversNames {
    static let styleResolver: String = "RewardsRequirementStyle"
}

// MARK: - RewardDetailQRCapable

public protocol RewardDetailQRCapable {
    var areRewardsCodeQRCapable: Bool { get }
    var qrMiddleImage: UIImage? { get }
}

public extension RewardDetailQRCapable {
    var qrMiddleImage: UIImage? { nil }
}

public extension Notification.Name {
    static var forceReloadRewardsList: Notification.Name { Notification.Name("reloadAfterFailureNotification") }
}
