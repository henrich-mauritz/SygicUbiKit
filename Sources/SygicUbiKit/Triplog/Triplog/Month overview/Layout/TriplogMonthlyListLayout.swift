import UIKit

class TriplogMonthlyListLayout: TriplogMonthlyLayout {
    private var sectionizedTrips: [TriplogDateSectionTripModelProtocol]?

    override var currentTrips: [TriplogTripCardViewModelProtocol] {
        didSet {
            sectionizedTrips = delegate?.sectionizedTrips
        }
    }

    override public init(collectionView: UICollectionView, delegate: TriplogMonthlyLayoutDelegate? = nil) {
        super.init(collectionView: collectionView, delegate: delegate)
        sectionizedTrips = delegate?.sectionizedTrips
    }

    //MARK: - CollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (sectionizedTrips?.count ?? 0) + 1
    }

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }

        guard let section = self.sectionizedTrips?[section - 1] else {
            return 0
        }
        return section.sectionTrips.count
    }

    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }

        guard let dateHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TriplogListDateheaderView.headerIdentifier, for: indexPath) as? TriplogListDateheaderView,
        let sections = sectionizedTrips else {
            fatalError("no header")
        }
        let sectionModel = sections[indexPath.section - 1]
        dateHeader.update(title: sectionModel.sectionTitle)
        return dateHeader
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        if section == 0 {
            return CGSize(width: width, height: 80)
        }

        return CGSize(width: width, height: 30)
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TriplogListCollectionViewCell.cellIdentifier, for: indexPath) as? TriplogListCollectionViewCell,
            let sections = sectionizedTrips else {
            fatalError("The cell type wasn't registered")
        }

        let sectionModel = sections[indexPath.section - 1]
        cell.update(with: sectionModel.sectionTrips[indexPath.row])
        return cell
    }

    //MARK: - CollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = CGSize(width: collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right), height: 90)
        return itemSize
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       return 0
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
