import Foundation

public protocol BadgesListViewModelType {
    var badgeList: [BadgeItemType]? { get }
    var delegate: BadgesListViewModelDelegate? { get set }
    func loadData(purginCache: Bool)
}
