
import Foundation
import UIKit

// MARK: - TriplogMonthlyLayoutDelegate

public protocol TriplogMonthlyLayoutDelegate: AnyObject {
    var currentTrips: [TriplogTripCardViewModelProtocol] { get }
    var sectionizedTrips: [TriplogDateSectionTripModelProtocol] { get }
    var headerInfo: TriplogScoreHeaderViewProtocol { get }
    var isLoading: Bool { get }
    func shouldLoadMoreTrips()
    func didSelectItem(at indexPath: IndexPath)
}

public extension TriplogMonthlyLayoutDelegate {
    var sectionizedTrips: [TriplogDateSectionTripModelProtocol] { return [] }
}

// MARK: - TriplogMonthlyLayout

public class TriplogMonthlyLayout: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let collectionView: UICollectionView
    var currentTrips: [TriplogTripCardViewModelProtocol] = []
    var style: TriplogMonthlyListingType = TripLogSettingsManager.shared.currentSettings.defaultLayout

    weak var delegate: TriplogMonthlyLayoutDelegate?

    /// Factory Method for layouts
    /// - Parameter style: layout style
    class func layout(for collectionView: UICollectionView,
                      with style: TriplogMonthlyListingType,
                      delegate: TriplogMonthlyLayoutDelegate?) -> TriplogMonthlyLayout {
        var layout: TriplogMonthlyLayout
        switch style {
        case .grid:
            layout = TripLogMonthlyGridLayout(collectionView: collectionView, delegate: delegate)
        default:
            layout = TriplogMonthlyListLayout(collectionView: collectionView, delegate: delegate)
        }
        layout.currentTrips = delegate?.currentTrips ?? []
        layout.style = style
        return layout
    }

    public init(collectionView: UICollectionView, delegate: TriplogMonthlyLayoutDelegate? = nil) {
        self.collectionView = collectionView
        self.delegate = delegate
        super.init()
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    /// Will return default the score header
    /// - Parameters:
    ///   - collectionView: colleciton View
    ///   - kind: UICollectionView.elementKindSectionHeader
    ///   - indexPath: indexPath
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TriplogScoreCollectionHeaderView.headerIdentifier, for: indexPath)

        if let view = view as? TriplogScoreCollectionHeaderView, let delegate = self.delegate {
            view.update(with: delegate.headerInfo)
        }

        return view
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Please implement the subclass")
    }

    public func reload(invalidateLayout: Bool = false) {
        if invalidateLayout {}
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = self.delegate else {
            return
        }

        delegate.didSelectItem(at: indexPath)
    }
}
