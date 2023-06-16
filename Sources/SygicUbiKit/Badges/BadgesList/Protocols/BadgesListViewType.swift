import Foundation
import UIKit

// MARK: - BadgesListDelegate

public protocol BadgesListDelegate where Self: AnyObject {
    func listViewDidSelectBadge(with id: String)
}

// MARK: - BadgesListViewType

public protocol BadgesListViewType where Self: UIView {
    var viewModel: BadgesListViewModelType? { set get }
    var delegate: BadgesListDelegate? { set get }
    var collectionView: UICollectionView { get }
    func registerCollectionComponents()
    func reloadList()
    func toggleLoadingIndicator(value: Bool)
}

// MARK: - BadgeItemCellConfigurable

public protocol BadgeItemCellConfigurable {}
