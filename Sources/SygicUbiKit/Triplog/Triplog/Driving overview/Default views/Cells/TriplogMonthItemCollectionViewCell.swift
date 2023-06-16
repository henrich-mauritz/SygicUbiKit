import UIKit

class TriplogMonthItemCollectionViewCell: UICollectionViewCell, InjectableType {
    override var reuseIdentifier: String? { return TriplogMonthItemCollectionViewCell.cellIdentifier }

    private lazy var monthCardView: TriplogOverviewMonthCardProtocol = {
        guard let monthView = container.resolve(TriplogOverviewMonthCardProtocol.self) else {
            fatalError("No TriplogOverviewMonthCardProtocol has been injected yet, please check the module main class")
        }
        return monthView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.cover(with: monthCardView, insets: NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
    }

    public func configureWith(item: TriplogOverviewCardViewModelProtocol) {
        monthCardView.viewModel = item
    }
}
