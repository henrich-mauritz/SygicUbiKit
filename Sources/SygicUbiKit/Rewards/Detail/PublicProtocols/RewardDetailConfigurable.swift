import Foundation

/// Configurable protocol, add more properties that lets the view configure in certain way after injecting from within the app side
public protocol RewardDetailConfigurable {
    var hideValidityDate: Bool { get }
}
