import Foundation
import UIKit

// MARK: - ProgressColoring

public protocol ProgressColoring {
    var progressColor: UIColor? { get }
}

public extension ProgressColoring {
    var progressColor: UIColor? { return .positivePrimary }
}
