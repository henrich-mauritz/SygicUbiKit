import Foundation
import UIKit

// MARK: - MonthlyOtherStatType

public protocol MonthlyOtherStatType {
    var value: String { get }
    var description: String { get }
}

// MARK: - MonthlyStatsOtherStatsCell

class MonthlyStatsOtherStatsCell: UITableViewCell {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 160, height: 84)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        layout.minimumInteritemSpacing = 10
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(MonthlyStatsOtherCollectionCell.self, forCellWithReuseIdentifier: MonthlyStatsOtherCollectionCell.cellIdentifier)
        collection.dataSource = self
        collection.delegate = self
        collection.showsHorizontalScrollIndicator = true
        collection.heightAnchor.constraint(equalToConstant: 114).isActive = true
        return collection
    }()

    private lazy var leftGradient: GradientDrawView = {
        let gradient = GradientDrawView(frame: .zero, direction: .leftToRight)
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.widthAnchor.constraint(equalToConstant: 40).isActive = true
        gradient.colors = [Styling.backgroundPrimary, Styling.backgroundPrimary.withAlphaComponent(0.0)]
        return gradient
    }()

    private lazy var rightGradient: GradientDrawView = {
        let gradient = GradientDrawView(frame: .zero, direction: .rightToLeft)
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.widthAnchor.constraint(equalToConstant: 40).isActive = true
        gradient.colors = [Styling.backgroundPrimary, Styling.backgroundPrimary.withAlphaComponent(0.0)]
        return gradient
    }()

    private var items: [MonthlyOtherStatType] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.cover(with: collectionView)
        contentView.addSubview(leftGradient)
        contentView.addSubview(rightGradient)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(leftGradient.leadingAnchor.constraint(equalTo: contentView.leadingAnchor))
        constraints.append(leftGradient.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(leftGradient.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        constraints.append(rightGradient.trailingAnchor.constraint(equalTo: contentView.trailingAnchor))
        constraints.append(rightGradient.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(rightGradient.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with items: [MonthlyOtherStatType]) {
        self.items = items
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension MonthlyStatsOtherStatsCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthlyStatsOtherCollectionCell.cellIdentifier, for: indexPath) as? MonthlyStatsOtherCollectionCell else {
            fatalError("NO MonthlyStatsOtherCollectionCell cell registered yet")
        }
        cell.update(with: items[indexPath.row])
        return cell
    }
}
