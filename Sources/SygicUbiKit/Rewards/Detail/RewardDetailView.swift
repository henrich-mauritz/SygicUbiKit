import UIKit

// MARK: - RewardDetailViewProtocol

public protocol RewardDetailViewProtocol where Self: UIView {
    func update(with viewModel: RewardDetailViewModelProtocol)
    func restoreUIAfterError(error: Error)
}

// MARK: - RewardDetailView

public class RewardDetailView: UIView, RewardDetailViewProtocol, InjectableType {
    private var viewModel: RewardDetailViewModelProtocol?

    private let scrollView = UIScrollView()

    private lazy var rootStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = margin
        return stack
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = margin
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: margin, bottom: 0, trailing: margin)
        return stack
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        return imageView
    }()

    private let gradientView: GradientDrawView = {
        let gradient = GradientDrawView()
        gradient.colors = [
            UIColor.backgroundPrimary.withAlphaComponent(0),
            .backgroundPrimary,
        ]
        return gradient
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.bold, with: 34)
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        sectionLabel()
    }()

    private lazy var requirementsTitle: UILabel = {
        let label = sectionLabel()
        label.text = "rewards.detail.requirementsTitle".localized
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        textLabel()
    }()

    private lazy var howToTitle: UILabel = {
        let label = sectionLabel()
        label.text = "rewards.detail.howToTitle".localized
        return label
    }()

    private lazy var howToDescription: UILabel = {
        let label = textLabel()
        label.text = "rewards.detail.howToDescription".localized
        return label
    }()

    private lazy var participatingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.regular, with: 20)
        label.numberOfLines = 3
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.text = "rewards.detail.alreadyParticipatingTitle".localized
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 72).isActive = true
        return label
    }()

    private lazy var participatingLabelViewContainer: UIView = {
       let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = Styling.buttonBackgroundSecondary.cgColor
        view.layer.cornerRadius = Styling.cornerRadius
        view.cover(with: participatingLabel, insets: NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
       return view
    }()

    private lazy var participatingAdditionalLebel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.thin, with: 14)
        label.numberOfLines = 0
        return label
    }()

    private lazy var participateButton: StylingButton = {
        let button = StylingButton.button(with: .normal)
        button.titleLabel.text = "rewards.detail.participateButton".localized
        button.addTarget(self, action: #selector(self.participateButtonPressed(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var termsAndConditionsCheckmark: CheckmarkView = {
        let checkMark = CheckmarkView()
        checkMark.isSelected = viewModel?.termsAndConditions?.agreedToTermsAndConditions ?? false
        checkMark.addTarget(self, action: #selector(self.termsAndConditionsCheckmarkPressed(_:)), for: .touchUpInside)
        return checkMark
    }()

    private lazy var termsAndConditionsTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .foregroundPrimary
        textView.tintColor = .foregroundPrimary
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.sizeToFit()
        return textView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .foregroundPrimary
        return indicator
    }()

    private let margin: CGFloat = 16

    //MARK: - Public

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func restoreUIAfterError(error _: Error) {
        // Here ideally if we were to put more error types we could update the UI accordingly based on the error type
        if termsAndConditionsCheckmark.superview != nil {
            participateButton.isEnabled = true
            termsAndConditionsCheckmark.isEnabled = true
        }
        activityIndicator.stopAnimating()
    }

    //MARK: - RewardDetailViewProtocol

    public func update(with viewModel: RewardDetailViewModelProtocol) {
        activityIndicator.stopAnimating()
        self.viewModel = viewModel
        UIImage.loadImage(from: viewModel.imageUri) { [weak self] _, image, _ in
            self?.imageView.image = image
        }

        if viewModel.loading {
            activityIndicator.startAnimating()
            return
        } else {
            activityIndicator.stopAnimating()
        }
        titleLabel.text = viewModel.title
        contentStack.removeAll()
        addLabel(subtitleLabel, with: viewModel.subtitle)
        addLabel(descriptionLabel, with: viewModel.description)
        if viewModel.type == .custom {
            let loyalityCardView = RewardsLoalityCardView()
            var finalValidity: String?
            if viewModel.isUnlimited {
                finalValidity = "rewards.detail.validityUnlimited".localized
            } else {
                finalValidity = "\("rewards.detail.validityLimited".localized) \(viewModel.rewardValid ?? "")"
            }
            loyalityCardView.update(viewModel.gainedRewardAdditionalText, validity: finalValidity)
            contentStack.addArrangedSubview(loyalityCardView)
            return
        } else {
            if viewModel.state == .eligibleForReward {
                let eligebleView = RewardEligibleStateItemView()
                eligebleView.delegate = self
                contentStack.addArrangedSubview(eligebleView)
                return
            } else if viewModel.rewardCode == nil && viewModel.state == .none {
                setupRequirements(viewModel.requirements)
                requirementsTitle.text = viewModel.requirementsSubtitle
            } else if viewModel.state == .gained {
                if let qrCodable = container.resolve(RewardDetailQRCapable.self),
                   qrCodable.areRewardsCodeQRCapable {
                    setupRewardCodeView(viewModel.rewardCode,
                                        valid: viewModel.rewardValid,
                                        isQRCode: true,
                                        middleImage: qrCodable.qrMiddleImage)
                } else {
                    setupRewardCodeView(viewModel.rewardCode,
                                        valid: viewModel.rewardValid)
                }
            }
        }

        setupBottomInformation()
    }

    //MARK: - Private

    private func sectionLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.numberOfLines = 0
        return label
    }

    private func textLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.numberOfLines = 0
        return label
    }

    private func addLabel(_ label: UILabel, with text: String?) {
        guard let text = text else { return }
        label.text = text
        contentStack.addArrangedSubview(label)
    }

    private func setupLayout() {
        backgroundColor = .backgroundPrimary
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        addSubview(activityIndicator)
        scrollView.addSubview(rootStack)
        imageView.addSubview(gradientView)
        imageView.addSubview(titleLabel)

        var constraints = [NSLayoutConstraint]()
        constraints.append(scrollView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(scrollView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(scrollView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(scrollView.trailingAnchor.constraint(equalTo: trailingAnchor))

        constraints.append(scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: rootStack.topAnchor))
        constraints.append(scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: rootStack.bottomAnchor, constant: 10))
        constraints.append(scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: rootStack.leadingAnchor))
        constraints.append(scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: rootStack.trailingAnchor))
        constraints.append(scrollView.widthAnchor.constraint(equalTo: rootStack.widthAnchor, multiplier: 1))

        constraints.append(gradientView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor))
        constraints.append(gradientView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor))
        constraints.append(gradientView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor))
        constraints.append(gradientView.heightAnchor.constraint(equalToConstant: 150))

        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: margin))
        constraints.append(titleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -margin))

        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))

        constraints.append(imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 230))
        NSLayoutConstraint.activate(constraints)

        rootStack.addArrangedSubview(imageView)
        rootStack.addArrangedSubview(contentStack)
    }

    private func setupRequirements(_ requirements: [RewardRequirement]?) {
        guard let requirements = requirements, requirements.count > 0 else { return }
        contentStack.addArrangedSubview(requirementsTitle)
        contentStack.addArrangedSubview(RequirementsView(with: requirements))
        var requirementsFullfiled = true
        for requirement in requirements {
            if !requirement.isFulfilled {
                requirementsFullfiled = false
            }
        }
        termsAndConditionsCheckmark.isEnabled = requirementsFullfiled
    }

    private func setupRewardCodeView(_ code: String?,
                                     valid: String?,
                                     isQRCode: Bool = false,
                                     middleImage: UIImage? = nil) {
        guard let code = code, let viewModel = self.viewModel else { return }
        let codeView: RewardDiscountCodeView
        var validity = ""
        if viewModel.isUnlimited {
            validity = "rewards.code.validityUnlimited".localized
        } else {
            validity = "\("rewards.code.validityLimited".localized) \(valid ?? "")"
        }
        if isQRCode {
            let qrCodeView = RewardQRCodeStyleView()
            qrCodeView.update(code, validity: validity, middleImage: middleImage)
            codeView = qrCodeView
        } else {
            codeView = RewardDiscountCodeView()
            codeView.update(code, validity: validity)
        }
        contentStack.addArrangedSubview(codeView)
    }

    private func termAndConditionsAttributedString(from string: String) -> NSAttributedString {
        let termsAttrString = NSMutableAttributedString(string: string, attributes: [
            NSAttributedString.Key.font: UIFont.stylingFont(.regular, with: 16),
            NSAttributedString.Key.foregroundColor: UIColor.foregroundPrimary,
        ])
        if let url = viewModel?.termsAndConditions?.termsAndConditionsUri, let range = string.range(of: string) {
            termsAttrString.addAttributes([
                NSAttributedString.Key.link: url,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            ], range: NSRange(range, in: string))
        }
        return termsAttrString
    }

    private func setupBottomInformation() {
        guard let viewModel = viewModel else { return }
        switch viewModel.state {
        case .none:
            if let howToInstructions = viewModel.instructions, howToInstructions.title.count != 0, howToInstructions.description.count != 0 {
                howToTitle.text = howToInstructions.title
                howToDescription.text = howToInstructions.description
                contentStack.addArrangedSubview(howToTitle)
                contentStack.addArrangedSubview(howToDescription)
            }
            if viewModel.participating {
                contentStack.addArrangedSubview(participatingLabelViewContainer)
            } else if let toc = viewModel.termsAndConditions {
                let termsStack = UIStackView()
                termsStack.alignment = .center
                termsStack.spacing = margin
                termsStack.addArrangedSubview(termsAndConditionsCheckmark)
                termsStack.addArrangedSubview(termsAndConditionsTextView)
                contentStack.addArrangedSubview(termsStack)
                let stack = UIStackView()
                stack.layoutMargins = UIEdgeInsets(top: 0, left: 22, bottom: 22, right: 22)
                stack.distribution = .fill
                stack.isLayoutMarginsRelativeArrangement = true
                stack.addArrangedSubview(participateButton)
                contentStack.addArrangedSubview(stack)
                enableParticipateButton()
                let attString = termAndConditionsAttributedString(from: toc.text)
                termsAndConditionsTextView.attributedText = attString
            }
        case .gained:
                participatingAdditionalLebel.text = viewModel.gainedRewardAdditionalText
                contentStack.addArrangedSubview(participatingAdditionalLebel)
        default:
            print("Nothing to do")
        }
    }

    private func enableParticipateButton() {
        var requirementsFullfiled = true
        if let requirements = viewModel?.requirements {
            for requirement in requirements {
                if !requirement.isFulfilled {
                    requirementsFullfiled = false
                }
            }
        }
        participateButton.isEnabled = termsAndConditionsCheckmark.isSelected && requirementsFullfiled
    }

    @objc private func termsAndConditionsCheckmarkPressed(_ sender: Any) {
        enableParticipateButton()
    }

    @objc private func participateButtonPressed(_ sender: Any) {
        guard let viewModel = viewModel else { return }
        participateButton.isEnabled = false
        termsAndConditionsCheckmark.isEnabled = false
        activityIndicator.startAnimating()
        viewModel.participate()
    }
}

// MARK: RewardEligibleStateItemViewDelegate

extension RewardDetailView: RewardEligibleStateItemViewDelegate {
    func didTapGetReward() {
        activityIndicator.startAnimating()
        viewModel?.claimEligibleReward()
    }
}
