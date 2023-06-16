import UIKit

// MARK: - EmptyMonthlyStatViewModel

public struct EmptyMonthlyStatViewModel {
    var title: String
    var subtitle: String
    var image: UIImage?
}

// MARK: - EmptyMonthStatsView

public class EmptyMonthStatsView: UIView {
    private lazy var imageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "emptyMonthStats", in: .module, compatibleWith: nil))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.heightAnchor.constraint(equalToConstant: 225).isActive = true
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "monthlyStats.overview.emptyTitle".localized
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "monthlyStats.overview.emptySubtitle".localized
        label.numberOfLines = 0
        return label
    }()

    public init(with viewModel: EmptyMonthlyStatViewModel) {
        super.init(frame: .zero)
        setupLayout()
        self.titleLabel.text = viewModel.title
        self.subtitleLabel.text = viewModel.subtitle
        self.imageView.image = viewModel.image
    }

    private let kMargin: CGFloat = 32

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 61))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -61))
        constraints.append(imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kMargin))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kMargin))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: kMargin))
        constraints.append(subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kMargin))
        constraints.append(subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kMargin))
        constraints.append(subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10))
        NSLayoutConstraint.activate(constraints)
    }

    public func configure(with title: String, subtitle: String) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }
}
