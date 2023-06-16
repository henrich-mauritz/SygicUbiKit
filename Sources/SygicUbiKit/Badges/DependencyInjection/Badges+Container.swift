import Foundation
import Swinject

//MARK: - Registration

extension Container {
    func injectBadgeRepo() {
        injectNetworkRepo()
        injectCacheRepo()
        register(BadgesRepositoryType.self) {[unowned self] _ in
            BadgeRepository(networkRepo: self.resolveNetworkRepo(), cacheRepo: self.resolveCacheRepo())
        }
    }

    //TODO: have to implement when cloud is ready
    /// For now it will return mock data
    private func injectNetworkRepo() {
        if let _ = resolve(BadgesNetworkRepositoryType.self) {
            //overriden by app
            return
        }

        register(BadgesNetworkRepositoryType.self) { _ -> BadgesNetworkRepositoryType in
            BadgeNetworkRepository()
        }
    }

    //TODO: have to implement when cloud is ready
    private func injectCacheRepo() {
        if let _ = resolve(BadgesRepositoryType.self) {
            //overriden by app
            return
        }
        register(BadgesCacheRepositoryType.self) { _ -> BadgesCacheRepositoryType in
            BadgeCacheRepository()
        }.inObjectScope(.container)
    }
}

//MARK: - Resolver

extension Container {
    fileprivate func resolveNetworkRepo() -> BadgesNetworkRepositoryType {
        guard let netRepo = resolve(BadgesNetworkRepositoryType.self) else {
            fatalError("No Badges network repo registered yet")
        }

        return netRepo
    }

    fileprivate func resolveCacheRepo() -> BadgesCacheRepositoryType {
        guard let cacheRepo = resolve(BadgesCacheRepositoryType.self) else {
            fatalError("No cache repo registered yet")
        }
        return cacheRepo
    }

    public func resolveBadgesRepo() -> BadgesRepositoryType {
        guard let badgeRepo = resolve(BadgesRepositoryType.self) else {
            fatalError("Ooops the badges repo wasn't registered at all")
        }

        return badgeRepo
    }
}
