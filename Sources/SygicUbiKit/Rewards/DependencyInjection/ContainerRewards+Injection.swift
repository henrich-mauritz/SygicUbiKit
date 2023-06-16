import Foundation
import Swinject

extension Container {
    //MARK: Overview

    func injectRewardsRepo() {
        injectNetworkRepo()
        injectCacheRepo()
        register(RewardsRepositoryType.self) { resolver -> RewardsRepositoryType in
            guard let networkRepo = resolver.resolve(RewardsNetworkRepositoryType.self),
                  let cacheRepo = resolver.resolve(RewardsCacheRepositoryType.self) else {
                fatalError("Didn't register any netowork or local repo")
            }
            return RewardsRepository(with: networkRepo, cacheRepo: cacheRepo)
        }
    }

    private func injectNetworkRepo() {
        if let _ = resolve(RewardsNetworkRepositoryType.self) {
            //overriden by app
            return
        }

        register(RewardsNetworkRepositoryType.self) { _ -> RewardsNetworkRepositoryType in
            RewardsNetworkRepository()
        }
    }

    private func injectCacheRepo() {
        if let _ = resolve(RewardsCacheRepositoryType.self) {
            //overriden by app
            return
        }

        register(RewardsCacheRepositoryType.self) { _ -> RewardsCacheRepositoryType in
            RewardsCacheRepository()
        }.inObjectScope(.container)
    }
}

//MARK: - RESOLVERS

extension Container {
    func resolveRewardsRepo() -> RewardsRepositoryType {
        guard let repo = resolve(RewardsRepositoryType.self) else {
            fatalError("no repo registered, this is a mistake, please register some repo that conforms to TriplogRepositoryType")
        }
        return repo
    }
}
