import Foundation
import UIKit

// MARK: - BadgeDetailViewModelDelegate

public protocol BadgeDetailViewModelDelegate: AnyObject {
    func viewModelDidUpdate(viewModel: BadgeViewModelDetailType)
    func viewModelDidFail(viewModel: BadgeViewModelDetailType, error: Error)
}

// MARK: - BadgeViewModelDetailType

public protocol BadgeViewModelDetailType {
    var badgeId: String { get }
    var badgeDetail: BadgeItemDetailType? { get set }
    var delegate: BadgeDetailViewModelDelegate? { get set }
    var levelString: String { get }
    var imageLightUri: String { get }
    var imageDarkUri: String { get }
    var levelBackgroundColor: UIColor { get }
    var badgeBackgroundColor: UIColor { get }
    var currentProgress: CGFloat { get }
    var progressString: String? { get }
    func loadDetail()
}
