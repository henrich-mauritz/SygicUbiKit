import Foundation
import UIKit

public protocol MonthlyStatsViewType where Self: UIView {
    var viewModel: MonthlyStatsViewModelType? { set get }
    var errorView: UIView { get }
    var delegate: MonthlyStatsViewDelegate? { get set }
    func toggleLoadingIndicator(value: Bool)
    func toggleEmptyState(value: Bool)
    func stopRefreshing(fromError: Bool)
}
