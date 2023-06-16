import UIKit

// MARK: - TripLogMonthlyGridLayout

public class TripLogMonthlyGridLayout: TriplogMonthlyLayout {
        override public init(collectionView: UICollectionView, delegate: TriplogMonthlyLayoutDelegate? = nil) {
            super.init(collectionView: collectionView, delegate: delegate)
        }

        override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            guard let _ = self.delegate else {
                return 0
            }
            return currentTrips.count
        }

        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: 300, height: 80) //change to CGSize(width: 300, height: 150) if you want selector
        }

        override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TriplogTripCollectionCell.cellIdentifier, for: indexPath) as! TriplogTripCollectiocCellProtocol
            let tripViewModel = currentTrips[indexPath.item]
            cell.update(with: tripViewModel)
            return cell
        }
}

public extension TripLogMonthlyGridLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + collectionView.contentInset.right)) / 2
        return CGSize(width: itemSize, height: itemSize * 1.05)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        collectionView.contentInset.top
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: collectionView.contentInset.top * 2, left: 0, bottom: 0, right: 0)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let delegate = self.delegate else {
            return
        }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height * 4 {
            delegate.shouldLoadMoreTrips()
        }
    }
}
