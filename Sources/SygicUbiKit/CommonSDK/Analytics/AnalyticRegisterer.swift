import Foundation
import Swinject

// MARK: - AnalyticsRegistering

public protocol AnalyticsRegistering {
    func registerAnalytic(with key: String, parameters: [String: String]?)
}

// MARK: - AnalyticsRegisterer

public class AnalyticsRegisterer: InjectableType {
    public static let shared = AnalyticsRegisterer()

    public func registerAnalytic(with key: String, parameters: [String: String]?) {
        guard let registerer = container.resolve(AnalyticsRegistering.self) else {
            return
        }
        registerer.registerAnalytic(with: key, parameters: parameters)
    }
}
