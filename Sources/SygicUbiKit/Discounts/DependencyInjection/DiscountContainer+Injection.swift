import Foundation
import Swinject

//MARK: - Injectable

extension Container {
    func injectOverviewDiscountRepo() {
        guard resolve(DiscountsOverviewRepositoryType.self) == nil else { return }
        injectOverviewDiscountNetworkRepo()
        register(DiscountsOverviewRepositoryType.self) { resolver -> DiscountsOverviewRepositoryType in
//            guard let networkRepo = resolver.resolve(DiscountsOverviewNetworkRepositoryType.self) else {
//                fatalError("Didn't register any netowork or local repo")
//            }
            
            let networkRepo = DiscountsOverviewNetworkRepository()
            return DiscountsOverviewRepository(networkRepository: networkRepo)
        }
    }

    private func injectOverviewDiscountNetworkRepo() {
        if let _ = resolve(DiscountsOverviewNetworkRepositoryType.self) {
            // overriden by app
            return
        }

        register(DiscountsOverviewNetworkRepositoryType.self) { _ -> DiscountsOverviewNetworkRepositoryType in
            DiscountsOverviewNetworkRepository()
        }
    }

    private func injectDiscountCodeNetworkRepo() {
        if let _ = resolve(DiscountCodesNewtorkRepositoryType.self) {
            // override by app
            return
        }

        register(DiscountCodesNewtorkRepositoryType.self) { _ -> DiscountCodesNewtorkRepositoryType in
            DiscountCodesProgressNetworkRepository()
        }
    }
}

//MARK: - Resolver

public extension Container {
    func resolveDiscountOverviewRepo() -> DiscountsOverviewRepositoryType {
        guard let repo = resolve(DiscountsOverviewRepositoryType.self) else {
            fatalError("No discount repository has been registered")
        }

        return repo
    }

    func resolveDiscountCodeRepo() -> DiscountCodesRepositoryType {
        guard let repo = resolve(DiscountCodesRepositoryType.self) else {
            fatalError("No discount code repository has been registered")
        }
        return repo
    }
    
    func injectDiscountCodeRepository() {
        injectDiscountCodeNetworkRepo()
        register(DiscountCodesRepositoryType.self) { resolver -> DiscountCodesRepositoryType in
//            guard let networkRepo = resolver.resolve(DiscountCodesNewtorkRepositoryType.self) else {
//                fatalError("Didn't register any discount code network repo")
//            }
            let networkRepo = DiscountCodesProgressNetworkRepository()
            return DiscountCodesProgressRepository(with: networkRepo)
        }
    }
    
}
