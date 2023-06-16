import UIKit

public class MessageView: UIView {
    //MARK: - Properties

    var viewModel: MessageViewModelType? {
        didSet {
          configureVisuals()
        }
    }

    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 5
        sv.alignment = .center
        return sv
    }()

 //MARK: - LifeCycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        backgroundColor = .backgroundPrimary
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Layout and Visuals

    private func configureVisuals() {
        guard let viewModel = self.viewModel else {
            return
        }

        titleLabel.font = viewModel.titleFont
        messageLabel.font = viewModel.subtitleFont
        titleLabel.textColor = viewModel.titleColor
        messageLabel.textColor = viewModel.subtitleColor
        titleLabel.text = viewModel.title
        messageLabel.text = viewModel.message
        iconImageView.image = viewModel.image
        stackView.layoutIfNeeded()
    }

    private func setupLayout() {
        addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            //TODO: tento constraint mi pride navyse, tj. zbytocny. center + lead staci.
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
