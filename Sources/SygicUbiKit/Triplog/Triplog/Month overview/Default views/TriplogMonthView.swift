import UIKit

// MARK: - TriplogMonthView

public class TriplogMonthView: UIView, TriplogMonthViewProtocol {
    public weak var delegate: TriplogMonthViewDelegate?

    public var viewModel: TriplogCardViewModelProtocol?

    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .foregroundPrimary
        return indicator
    }()

    private var trips = [TriplogTripCardViewModelProtocol]()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear

        collectionView.register(TriplogTripCollectionCell.self, forCellWithReuseIdentifier: TriplogTripCollectionCell.cellIdentifier)
        collectionView.register(TriplogListCollectionViewCell.self, forCellWithReuseIdentifier: TriplogListCollectionViewCell.cellIdentifier)
        collectionView.register(TriplogScoreCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TriplogScoreCollectionHeaderView.headerIdentifier)
        collectionView.register(TriplogListDateheaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TriplogListDateheaderView.headerIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.refreshControl = refresher

        return collectionView
    }()

    private let margin: CGFloat = 16

    private var currentLayout: TriplogMonthlyLayout? {
        didSet {
            collectionView.reloadData()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.reloadData()
    }

    public func update(with viewModel: TriplogCardViewModelProtocol) {
        collectionView.collectionViewLayout.invalidateLayout()
        self.viewModel = viewModel
        self.trips = viewModel.trips
        if let currentLayout = self.currentLayout {
            if currentLayout.style != viewModel.listingType {
                self.currentLayout = TriplogMonthlyLayout.layout(for: collectionView, with: viewModel.listingType, delegate: self)
            } else {
               currentLayout.currentTrips = viewModel.trips
            }
        } else {
            currentLayout = TriplogMonthlyLayout.layout(for: collectionView, with: viewModel.listingType, delegate: self)
        }

        collectionView.refreshControl?.endRefreshing()
        collectionView.reloadData()
    }

    @objc
func reloadData() {
        delegate?.triplogMonthViewReloadTrips(self)
    }

    public func toggleActivityIndicator(value: Bool) {
        if value {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func setupLayout() {
        backgroundColor = .backgroundPrimary

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        addSubview(activityIndicator)
        var constraints = [NSLayoutConstraint]()
        constraints.append(collectionView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(collectionView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(collectionView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(collectionView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: TriplogMonthlyLayoutDelegate

//MARK: - TriplogMonthlyLayoutDelegate

extension TriplogMonthView: TriplogMonthlyLayoutDelegate {
    public func didSelectItem(at indexPath: IndexPath) {
        guard let currentLayout = self.currentLayout else {
            return
        }

        var tripViewModel: TriplogTripCardViewModelProtocol
        if currentLayout.style == .grid {
            tripViewModel = trips[indexPath.item]
        } else {
            tripViewModel = sectionizedTrips[indexPath.section - 1].sectionTrips[indexPath.row] //removing one because firs section is score header view
        }

        delegate?.triplogMonthViewDidSelect(self, trip: tripViewModel)
    }

    public var isLoading: Bool {
        return self.viewModel?.loading ?? false
    }

    public var currentTrips: [TriplogTripCardViewModelProtocol] {
        return self.trips
    }

    public var sectionizedTrips: [TriplogDateSectionTripModelProtocol] {
        return self.viewModel?.categorizedTrips ?? []
    }

    public var headerInfo: TriplogScoreHeaderViewProtocol {
        guard let viewModel = self.viewModel else {
            return TriplogDefaultHeaderInfo(drivingScoreText: "", drivingScoreDescription: "", kilometersDrivenText: "", kilometersDrivenDescription: "")
        }
        let headerInfo = TriplogDefaultHeaderInfo(drivingScoreText: viewModel.drivingScoreText,
                                                  drivingScoreDescription: viewModel.drivingScoreDescription,
                                                  kilometersDrivenText: viewModel.kilometersDrivenText,
                                                  kilometersDrivenDescription: viewModel.kilometersDrivenDescription)

        return headerInfo
    }

    public func shouldLoadMoreTrips() {
        if self.isLoading == false {
            delegate?.triplogMonthViewLoadMoreTrips(self)
        }
    }
}
