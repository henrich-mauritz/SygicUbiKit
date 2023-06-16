import Foundation
import Swinject

// MARK: - InjectableType

public protocol InjectableType {
    var container: Container { get }
}

public extension InjectableType {
    var container: Container {
        return SYInjector.container
    }
}

// MARK: - SYInjector

public struct SYInjector {
    public static var container: Container = Container()
}

public extension Container {
    func resolveOrInjectDefault<Service>(_ service: Service.Type, defaultFactory: @escaping (Resolver) -> Service) -> Service {
        if let resolved = resolve(service) {
            return resolved
        } else {
            register(service, factory: defaultFactory)
            guard let resolvedDefault = resolve(service) else {
                fatalError("Error resolving Default registration failed!")
            }
            print("\(Service.self) registered")
            return resolvedDefault
        }
    }
}
