import UIKit

// MARK: - TriplogOverviewTableViewMonthsCellDelgate

protocol TriplogOverviewTableViewMonthsCellDelgate where Self: AnyObject {
    func tripOverviewCellDidSelect(item: TriplogOverviewCardViewModelProtocol)
}

// MARK: - TriplogOverviewTableViewMonthsCell

class TriplogOverviewTableViewMonthsCell: UITableViewCell {
    override var reuseIdentifier: String? { TriplogOverviewTableViewMonthsCell.identifier }
    weak var delegate: TriplogOverviewTableViewMonthsCellDelgate?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 144, height: 260)
        layout.itemSize = CGSize(width: 144, height: 260)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumInteritemSpacing = 10
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(TriplogMonthItemCollectionViewCell.self, forCellWithReuseIdentifier: TriplogMonthItemCollectionViewCell.cellIdentifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.showsHorizontalScrollIndicator = false
        collection.heightAnchor.constraint(equalToConstant: 308).isActive = true
        return collection
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = Styling.backgroundSecondary
        return view
    }()

    private var items: [TriplogOverviewCardViewModelProtocol] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.cover(with: collectionView)
        contentView.addSubview(separatorView)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16))
        constraints.append(separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16))
        constraints.append(separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0))
        NSLayoutConstraint.activate(constraints)
    }

    public func configureWith(items: [TriplogOverviewCardViewModelProtocol]) {
        self.items = items
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension TriplogOverviewTableViewMonthsCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TriplogMonthItemCollectionViewCell.cellIdentifier, for: indexPath) as? TriplogMonthItemCollectionViewCell else {
            fatalError("NO TriplogMonthItemCollectionViewCell cell registered yet")
        }
        cell.configureWith(item: items[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.tripOverviewCellDidSelect(item: items[indexPath.item])
    }
}
