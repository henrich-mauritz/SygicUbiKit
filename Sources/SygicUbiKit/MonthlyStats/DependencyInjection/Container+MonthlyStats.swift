import Foundation
import Swinject

//MARK: - Registration

extension Container {
    func injectStatsRepo() {
        injectNetworkRepo()
        injectCacheRepo()
        register(MonthlyStatsRepositoryType.self) {[unowned self] _ in
            MonthlyStatsRepository(networkRepo: self.resolveNetworkRepo(), cahceRepo: self.resolveCacheRepo())
        }
    }

    private func injectNetworkRepo() {
        if let _ = resolve(MonthlyStatsNetworkRepositoryType.self) {
            //overriden by app
            return
        }
        register(MonthlyStatsNetworkRepositoryType.self) { _ -> MonthlyStatsNetworkRepositoryType in
            MonthlyStatsNetworkRepository()
        }
    }

    private func injectCacheRepo() {
        if let _ = resolve(MonthlyStatsRepositoryType.self) {
            //overriden by app
            return
        }
        register(MonthlyStatsCacheRepositoryType.self) { _ -> MonthlyStatsCacheRepositoryType in
            MonthlyStatsCacheRepository()
        }.inObjectScope(.container)
    }
}

//MARK: - Resolver

extension Container {
    fileprivate func resolveNetworkRepo() -> MonthlyStatsNetworkRepositoryType {
        guard let netRepo = resolve(MonthlyStatsNetworkRepositoryType.self) else {
            fatalError("No MonthlyStats network repo registered yet")
        }

        return netRepo
    }

    fileprivate func resolveCacheRepo() -> MonthlyStatsCacheRepositoryType {
        guard let cacheRepo = resolve(MonthlyStatsCacheRepositoryType.self) else {
            fatalError("No cache repo registered yet")
        }
        return cacheRepo
    }

    public func resolveMonthlyStatsRepo() -> MonthlyStatsRepositoryType {
        guard let badgeRepo = resolve(MonthlyStatsRepositoryType.self) else {
            fatalError("Ooops the MonthlyStats repo wasn't registered at all")
        }

        return badgeRepo
    }
}
