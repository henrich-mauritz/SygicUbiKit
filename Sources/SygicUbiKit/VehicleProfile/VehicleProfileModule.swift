import Foundation
import UIKit
import Swinject

// MARK: - VehicleProfileModule

public typealias VehicleType = ConfigurationVehicleType

// MARK: - VehicleProfileModule

public class VehicleProfileModule {
    private static var defaultsInjected: Bool = false
    static let kSelectedVehcileIdForDriving = "kSelectedVehcileIdForDriving"
    private init() {}

    /// Injects default module components and returns module entry view controller.
    /// - Returns: Module entry view controller
    public static func rootViewController() -> VehicleProfileListViewController {
        injectDefaults()
        return SYInjector.container.resolve(VehicleProfileListViewController.self)!
    }

    /// Injects default components to InjectableType container required for module.
    /// Call this function before injecting your custom components for this module. No need to call, if you use BadgesModule.rootViewController() for initializing
    public static func injectDefaults() {
        guard !defaultsInjected else { return }
        ConfigurationModule.fetchConfiguration { _ in } // just in case it wasn't loaded yet.
        let container = SYInjector.container
        injectNetworkRepo()
        injectCacheRepo()
        container.register(VehicleProfileRepositoryType.self) { resolver -> VehicleProfileRepositoryType in
//            guard let networkRepo = resolver.resolve(VehicleProfileNetworkRepositoryType.self),
//                  let cacheRepo = resolver.resolve(VehicleProfileCacheRepositoryType.self) else {
//                fatalError("Didn't register any netowork or local repo")
//            }
            let networkRepo = VehicleProfileNetworkRepository()
            let cacheRepo = VehicleProfileCacheRepository()
            return VehicleProfileRepository(cacheRepo: cacheRepo, networkRepo: networkRepo)
        }

        container.register(VehicleProfileListViewController.self) { _ -> VehicleProfileListViewController in
            VehicleProfileListViewController()
        }

        defaultsInjected = true
    }

    private static func injectNetworkRepo() {
        let container = SYInjector.container
        container.register(VehicleProfileNetworkRepositoryType.self) { _ in
            VehicleProfileNetworkRepository()
        }
    }

    private static func injectCacheRepo() {
        let container = SYInjector.container
        container.register(VehicleProfileCacheRepositoryType.self) { _ in
            VehicleProfileCacheRepository()
        }.inObjectScope(.container)
    }

    public static func currentDrivingVehicle() -> VehicleProfileType? {
        let container = SYInjector.container
        let repo = container.resolveVehicleProfileRepo()
        let selectedForDriving = repo.storedVehicles.first(where: { $0.isSelectedForDriving == true })
        return selectedForDriving
    }

    public static func hasMoreThanOneActiveVehcile() -> Bool {
        let container = SYInjector.container
        let repo = container.resolveVehicleProfileRepo()
        return repo.activeVehicles.count > 1
    }

    public static func presentOffSeasonPopUp(on controller: UIViewController) {
        let stylingPopController = StylingPopupViewController()
        let popupViewmodel = StylingPopUpViewModel(title: "vehicleProfile.offseason.title".localized,
                                                   subtitle: "vehicleProfile.offseason.subtitle".localized,
                                                   actionTitle: "vehicleProfile.offseason.buttonTitle".localized.uppercased(),
                                                   cancelTitle: nil,
                                                   image: UIImage(named: "offSeasson", in: .module, compatibleWith: nil))
        popupViewmodel.actionButtonAction = {
            stylingPopController.dismiss(animated: true, completion: nil)
        }
        stylingPopController.configure(with: popupViewmodel)
        controller.present(stylingPopController, animated: true, completion: nil)
    }
}

public extension Container {
    func resolveVehicleProfileRepo() -> VehicleProfileRepositoryType {
        guard let repo = resolve(VehicleProfileRepositoryType.self) else {
            fatalError("The repo wasn't injected, neither by defaults, or app")
        }
        return repo
    }
}

public extension Notification.Name {
    static var applicationDidChangeVehicleNotification: Notification.Name { Notification.Name("applicationDidChangeVehicleNotification") }
    static var vehicleProfileDidToggleVehicleActivation: Notification.Name { Notification.Name("vehicleProfileDidToggleVehicleActivation") }
}

// MARK: - VehicleProfileConfigurable

public protocol VehicleProfileConfigurable {
    var displayMaxVehiclesNote: Bool { get }
}

extension VehicleProfileConfigurable {
    var displayMaxVehiclesNote: Bool {
        return true
    }
}
