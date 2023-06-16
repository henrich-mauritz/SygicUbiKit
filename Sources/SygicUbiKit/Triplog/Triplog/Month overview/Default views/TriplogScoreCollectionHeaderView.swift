import UIKit

// MARK: - TriplogScoreHeaderViewProtocol

public protocol TriplogScoreHeaderViewProtocol {
    var drivingScoreText: String { get set }
    var drivingScoreDescription: String { get set }
    var kilometersDrivenText: String { get set }
    var kilometersDrivenDescription: String { get set }
}

// MARK: - TriplogDefaultHeaderInfo

struct TriplogDefaultHeaderInfo: TriplogScoreHeaderViewProtocol {
    var drivingScoreText: String

    var drivingScoreDescription: String

    var kilometersDrivenText: String

    var kilometersDrivenDescription: String
}

// MARK: - TriplogScoreCollectionHeaderView

class TriplogScoreCollectionHeaderView: UICollectionReusableView {
    private let scoreContentView: TriplogScoreHeaderView = {
       let scoreView = TriplogScoreHeaderView()
       scoreView.translatesAutoresizingMaskIntoConstraints = false
       return scoreView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(scoreContentView)
        var constraints = [NSLayoutConstraint]()
        constraints.append(scoreContentView.topAnchor.constraint(equalTo: self.topAnchor))
        constraints.append(scoreContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor))
        constraints.append(scoreContentView.leadingAnchor.constraint(equalTo: self.leadingAnchor))
        constraints.append(scoreContentView.trailingAnchor.constraint(equalTo: self.trailingAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    override var reuseIdentifier: String? {
        return TriplogScoreCollectionHeaderView.headerIdentifier
    }

    func update(with headerViewModel: TriplogScoreHeaderViewProtocol) {
        scoreContentView.leftTitleLabel?.text = headerViewModel.drivingScoreText
        scoreContentView.leftDescriptionLabel.text = headerViewModel.drivingScoreDescription
        scoreContentView.rightTitleLabel?.text = headerViewModel.kilometersDrivenText
        scoreContentView.rightDescriptionLabel.text = headerViewModel.kilometersDrivenDescription
    }
}
