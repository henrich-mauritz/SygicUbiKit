import UIKit

class TriplogEmptyState: UIView {
    var viewModel: TriplogEmtpyStateViewDelegate? {
        didSet {
            configureVisuals()
        }
    }

    //MARK: - Properties

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.heightAnchor.constraint(equalToConstant: 108).isActive = true
        iv.widthAnchor.constraint(equalToConstant: 280).isActive = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.thin, with: 30)
        label.textColor = .foregroundPrimary
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        return label
    }()

    //MARK: - LifeCycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -10),
            subtitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -10),
        ])
    }

    private func configureVisuals() {
        guard let viewModel = self.viewModel else {
            return
        }

        imageView.image = viewModel.image
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
}
