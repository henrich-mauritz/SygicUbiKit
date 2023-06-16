import UIKit

class FullScreenPopUpView: UIView {
    public let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "permissionsPopup", in: .module, compatibleWith: nil))
        imageView.clipsToBounds = false
        imageView.layer.masksToBounds = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.thin, with: 30)
        label.textColor = .foregroundModal
        label.numberOfLines = 0
        label.textAlignment = .center
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.textColor = .foregroundModal
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    public let settingsButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.normalModal)
        return button
    }()

    public let cancelButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.secondaryModal)
        return button
    }()

    public lazy var imageViewTitleConstraint: NSLayoutConstraint = {
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32)
    }()

    let buttonsStack = UIStackView()

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    var viewModel: StylingPopUpViewModelDataType? {
        didSet {
            self.configure()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupLayout() {
        self.backgroundColor = Styling.backgroundPrimary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(900), for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(UILayoutPriority(220), for: .vertical)

        buttonsStack.axis = .vertical
        buttonsStack.spacing = 16
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        buttonsStack.addArrangedSubview(settingsButton)
        buttonsStack.addArrangedSubview(cancelButton)

        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(buttonsStack)

        let imageViewHeight = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1)
        imageViewHeight.priority = UILayoutPriority(rawValue: 750)

        //Portrait Constraints
        var constraints = [NSLayoutConstraint]()
        constraints.append(imageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 32))
        constraints.append(imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0))
        constraints.append(imageViewHeight)
        constraints.append(imageViewTitleConstraint)

        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 43))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -43))
        constraints.append(titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -15))
        constraints.append(subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 43))
        constraints.append(subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -43))
        constraints.append(subtitleLabel.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -20))
        constraints.append(buttonsStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 43))
        constraints.append(buttonsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -43))
        constraints.append(buttonsStack.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -43))
        portraitConstraints = constraints
        NSLayoutConstraint.activate(portraitConstraints)
    }

    private func configure() {
        guard let viewModel = viewModel else {
            return
        }
        imageView.image = viewModel.image
        titleLabel.text = viewModel.title
        if let attSubtitle = viewModel.attributedSubtitle {
            subtitleLabel.attributedText = attSubtitle
        } else {
            subtitleLabel.text = viewModel.subtitle
        }
        cancelButton.titleLabel.text = viewModel.cancelButtonTitle
        settingsButton.titleLabel.text = viewModel.actionButtonTitle
        if let _ = viewModel.cancelButonAction {
            cancelButton.removeTarget(nil, action: nil, for: .allEvents)
            cancelButton.addTarget(self, action: #selector(FullScreenPopUpView.cancelPressed), for: .touchUpInside)
        } else {
            buttonsStack.removeArrangedSubview(cancelButton)
            cancelButton.removeFromSuperview()
        }
        if let _ = viewModel.actionButtonAction {
            settingsButton.removeTarget(nil, action: nil, for: .allEvents)
            settingsButton.addTarget(self, action: #selector(FullScreenPopUpView.settingsPressed), for: .touchUpInside)
        }
    }

    @objc
private func cancelPressed() {
    guard let action = self.viewModel?.cancelButonAction else {
            return
        }
        action()
    }

    @objc
private func settingsPressed() {
    guard let action = self.viewModel?.actionButtonAction else {
            return
        }
        action()
    }
}
