import Foundation
import Swinject

extension Container {
    //MARK: - General

    func injectTriplogRepositories() {
        injectOverViewRepo()
        injectMonthlyRepo()
        injectDetailRepo()
    }

    //MARK: - Overview

    private func injectOverViewRepo() {
        injectOverviewNetworkRepo()
        injectOverviewCacheRepo()
        register(TriplogOverviewRepositoryType.self) { resolver -> TriplogOverviewRepositoryType in
            guard let networkRepo = resolver.resolve(TriplogOverviewNetworkRepositoryType.self),
                  let cacheRepo = resolver.resolve(TriplogOverviewCacheRepositoryType.self) else {
                fatalError("Didn't register any netowork or local repo")
            }
            return TriplogOverviewRepository(with: networkRepo, cacheRepo: cacheRepo)
        }
    }

    private func injectOverviewNetworkRepo() {
        if let _ = resolve(TriplogOverviewNetworkRepositoryType.self) {
            //overriden by app
            return
        }

        register(TriplogOverviewNetworkRepositoryType.self) { _ -> TriplogOverviewNetworkRepositoryType in
            TriplogOverviewNetworkRepository()
        }
    }

    private func injectOverviewCacheRepo() {
        if let _ = resolve(TriplogOverviewCacheRepositoryType.self) {
            //overriden by app
            return
        }

        register(TriplogOverviewCacheRepositoryType.self) { _ -> TriplogOverviewCacheRepositoryType in
            TriplogOverviewCacheRepository()
        }.inObjectScope(.container)
    }

    //MARK: - Monthly

    private func injectMonthlyRepo() {
        injectMonthlyNetworkRepo()
        injectMonthlyCacheRepo()
        register(TriplogMonthlyRepositoryType.self) { resolver -> TriplogMonthlyRepositoryType in
            guard let networkRepo = resolver.resolve(TriplogMonthlyNewtworkRepositoryType.self),
                  let cacheRepo = resolver.resolve(TriplogMonthlyCacheRepositoryType.self) else {
                fatalError("Didn't register any netowork or local repo")
            }
            return TriplogMonthlyRepository(networkReposotory: networkRepo, cacheRepository: cacheRepo)
        }
    }

    private func injectMonthlyNetworkRepo() {
        if let _ = resolve(TriplogMonthlyNewtworkRepositoryType.self) {
            //overriden by app
            return
        }

        register(TriplogMonthlyNewtworkRepositoryType.self) { _ -> TriplogMonthlyNewtworkRepositoryType in
            TriplogMonthlyNetworkRepository()
        }
    }

    private func injectMonthlyCacheRepo() {
        if let _ = resolve(TriplogMonthlyCacheRepositoryType.self) {
            //overriden by app
            return
        }

        register(TriplogMonthlyCacheRepositoryType.self) { _ -> TriplogMonthlyCacheRepositoryType in
            TriplogMonthlyCacheRepository()
        }.inObjectScope(.container)
    }

    //MARK: - Detail

    private func injectDetailRepo() {
        injectDetailNetworkRepo()
        injectDetailCacheRepo()
        register(TripDetailRepositoryType.self) { resolver -> TripDetailRepositoryType in
            guard let networkRepo = resolver.resolve(TripDetailNetworkRepositoryType.self),
                  let cacheRepo = resolver.resolve(TripDetailCacheRepositoryType.self) else {
                fatalError("No repos injected for trip detail")
            }
            return TripDetailRepository(networkRepo: networkRepo, cacheRepo: cacheRepo)
        }
    }

    private func injectDetailNetworkRepo() {
        if let _ = resolve(TripDetailNetworkRepositoryType.self) {
            //overriden by app
            return
        }

        register(TripDetailNetworkRepositoryType.self) { _ -> TripDetailNetworkRepositoryType in
            TripDetailNetworkRepository()
        }
    }

    private func injectDetailCacheRepo() {
        if let _ = resolve(TripDetailCacheRepositoryType.self) {
            //overriden by app
            return
        }

        register(TripDetailCacheRepositoryType.self) { _ -> TripDetailCacheRepositoryType in
            TripDetailCacheRepository()
        }.inObjectScope(.container)
    }
}

//MARK: - RESOLVERS

extension Container {
    func resolveTriplogRepo() -> TriplogOverviewRepositoryType {
        guard let repo = resolve(TriplogOverviewRepositoryType.self) else {
            fatalError("no repo registered, this is a mistake, please register some repo that conforms to TriplogRepositoryType")
        }
        return repo
    }

    func resolveTriplogMonthlyRepo() -> TriplogMonthlyRepositoryType {
        guard let repo = resolve(TriplogMonthlyRepositoryType.self) else {
            fatalError("No monthly repo registered, this is a mistake, please register some repo that conforms to TriplogMonthlyRepositoryType")
        }

        return repo
    }

    func resolveTripDetailRepo() -> TripDetailRepositoryType {
        guard let repo = resolve(TripDetailRepositoryType.self) else {
            fatalError("No trip detail repo registered, this is a mistake, please register some repo that conforms to ripDetailRepositoryType.")
        }

        return repo
    }
}
