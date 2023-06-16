import UIKit

// MARK: - BadgesListView

class BadgesListView: UIView, BadgesListViewType, InjectableType {
    //MARK: - Properties

    var viewModel: BadgesListViewModelType? {
        didSet {
            emtpyListLabel.isHidden = true
            refreshControl.endRefreshing()
            collectionView.reloadData()
            guard let badgeList = viewModel?.badgeList, badgeList.count != 0 else {
                emtpyListLabel.isHidden = false
                return
            }
        }
    }

    weak var delegate: BadgesListDelegate?

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.dataSource = self
        colView.delegate = self
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.backgroundColor = .clear
        colView.refreshControl = refreshControl
        return colView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refresher = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: {[weak self] _ in
            self?.viewModel?.loadData(purginCache: true)
        }))
        return refresher
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .foregroundPrimary
        return indicator
    }()

    private lazy var emtpyListLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textColor = .foregroundPrimary
        label.text = "badges.emptyList".localized
        label.isHidden = true
        return label
    }()

    //MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        backgroundColor = .backgroundPrimary
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(collectionView)
        addSubview(emtpyListLabel)
        addSubview(loadingIndicator)
        var constrains: [NSLayoutConstraint] = []
        constrains.append(collectionView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constrains.append(collectionView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constrains.append(collectionView.topAnchor.constraint(equalTo: topAnchor))
        constrains.append(collectionView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constrains.append(loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        constrains.append(loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))
        constrains.append(emtpyListLabel.centerXAnchor.constraint(equalTo: centerXAnchor))
        constrains.append(emtpyListLabel.centerYAnchor.constraint(equalTo: centerYAnchor))
        NSLayoutConstraint.activate(constrains)
    }

    func registerCollectionComponents() {
        collectionView.register(BadgeItemCollectionViewCell.self, forCellWithReuseIdentifier: BadgeItemCollectionViewCell.cellIdentifier)
    }

    @objc
private func reloadData() {
        self.viewModel?.loadData(purginCache: true)
    }

    func reloadList() {
        collectionView.reloadData()
    }

    func toggleLoadingIndicator(value: Bool) {
        if value {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate

//MARK: - CollectionView delegates

extension BadgesListView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    //MARK: - DataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.badgeList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgeItemCollectionViewCell.cellIdentifier, for: indexPath) as? BadgeItemCollectionViewCell, let item = self.viewModel?.badgeList?[indexPath.item] else {
            fatalError()
        }

        cell.configure(with: item)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let halfWidth = bounds.width / 2
        return CGSize(width: halfWidth, height: (halfWidth * 0.97) + 10)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = self.viewModel?.badgeList?[indexPath.item] else {
            fatalError()
        }

        delegate?.listViewDidSelectBadge(with: item.id)
    }
}
