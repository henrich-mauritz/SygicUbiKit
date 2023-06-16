import Foundation

public protocol CommonConfigurable {
    var preferredLanguage: String? { get }
}

public class CommonDefaultConfiguration: CommonConfigurable {
    public var preferredLanguage: String? = nil
    
}

public class CommonConfigurator {
    public static let shared = CommonConfigurator()
    
    public var configuration: CommonConfigurable = CommonDefaultConfiguration()
}
