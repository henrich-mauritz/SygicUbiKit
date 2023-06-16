import Foundation
import UIKit

// MARK: - DiscountsChallengesView

public class DiscountsChallengesView: UIView {
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.minimumScaleFactor = 0.2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public lazy var challengeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = margin
        return stack
    }()

    public lazy var descriptionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 13
        return stack
    }()

    public let margin: CGFloat = 16

    public var viewModel: DiscountChallengeViewModelProtocol? {
        didSet {
            titleLabel.text = viewModel?.title
            descriptionLabel.text = viewModel?.description
            viewModel?.steps.forEach { stepViewModel in
                let stepView = ChallengeProgressView()
                stepView.viewModel = stepViewModel
                challengeStack.addArrangedSubview(stepView)
            }
            guard let viewModel = viewModel as? ChallengeViewModel else { return }
            descriptionStack.subviews.forEach { $0.removeFromSuperview() }
            if viewModel.isUnderRequirement() {
                let icon = UIImageView(image: UIImage(named: "warning", in: .module, compatibleWith: nil))
                icon.widthAnchor.constraint(equalToConstant: 23).isActive = true
                icon.contentMode = .scaleAspectFit
                descriptionStack.addArrangedSubview(icon)
                descriptionStack.addArrangedSubview(descriptionLabel)
                changeColorForProgress(color: .negativeSecondary)
            } else {
                descriptionStack.addArrangedSubview(descriptionLabel)
                changeColorForProgress(color: .positivePrimary)
            }
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(titleLabel)
        stack.setCustomSpacing(margin / 2, after: titleLabel)
        stack.addArrangedSubview(challengeStack)
        stack.setCustomSpacing(margin, after: challengeStack)
        stack.addArrangedSubview(descriptionStack)
        cover(with: stack)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func changeColorForProgress(color: UIColor) {
        challengeStack.subviews.forEach {
            let view = $0 as! ChallengeProgressView
            view.progressViewColor = color
        }
    }
}

// MARK: - ChallengeProgressView

public class ChallengeProgressView: UIView {
    public let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.thin, with: 36)
        label.textColor = .foregroundPrimary
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        return label
    }()

    public let progressView = ProgressStrip()

    public var progressViewColor: UIColor? {
        set {
            progressView.progressView.backgroundColor = newValue
        }

        get {
            progressView.progressView.backgroundColor
        }
    }

    public var viewModel: DiscountChallengeStepViewModelProtocol? {
        didSet {
            textLabel.text = viewModel?.stepProgressTitle
            if let subtitle = viewModel?.stepProgressSubtitle {
                descriptionLabel.text = subtitle
                stack.setCustomSpacing(0, after: textLabel)
                stack.setCustomSpacing(12, after: descriptionLabel)
            } else {
                descriptionLabel.isHidden = true
                stack.setCustomSpacing(12, after: textLabel)
            }

            progressView.progress = CGFloat(viewModel?.stepProgress ?? 0)
            progressView.textLabel.text = viewModel?.stepTargetAmount
            progressView.set(progressColor: viewModel?.progressColor)
        }
    }

    private let stack = UIStackView()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        stack.axis = .vertical
        stack.addArrangedSubview(textLabel)
        stack.addArrangedSubview(descriptionLabel)
        stack.addArrangedSubview(progressView)
        cover(with: stack)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
