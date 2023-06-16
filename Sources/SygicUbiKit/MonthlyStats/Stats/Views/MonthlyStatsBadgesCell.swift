import Foundation
import UIKit

// MARK: - MonthlyStatsBadgesCell

class MonthlyStatsBadgesCell: UITableViewCell {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        layout.minimumInteritemSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(MonthlyStatsBadgeCollectionViewCell.self, forCellWithReuseIdentifier: MonthlyStatsBadgeCollectionViewCell.cellIdentifier)
        collection.dataSource = self
        collection.delegate = self
        collection.showsHorizontalScrollIndicator = true
        collection.heightAnchor.constraint(equalToConstant: 200).isActive = true
        return collection
    }()

    let itemSize: CGSize = CGSize(width: 140, height: 200)

    private var items: [BadgeItemType] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.cover(with: collectionView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with items: [BadgeItemType]) {
        self.items = items
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension MonthlyStatsBadgesCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        itemSize
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthlyStatsBadgeCollectionViewCell.cellIdentifier, for: indexPath) as? MonthlyStatsBadgeCollectionViewCell else {
            fatalError("NO BadgeItemCollectionViewCell cell registered yet")
        }
        cell.configure(with: items[indexPath.item])
        return cell
    }
}
