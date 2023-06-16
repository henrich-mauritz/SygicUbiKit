import UIKit

// MARK: - BadgeDetailViewConfigurable

public protocol BadgeDetailViewConfigurable where Self: UIView {
    var viewModel: BadgeViewModelDetailType? { get set }
}

// MARK: - BadgeDetailView

public class BadgeDetailView: UIView, BadgeDetailViewConfigurable {
    //MARK: - Properties

    public var viewModel: BadgeViewModelDetailType? {
        didSet {
            self.configureVisuals()
        }
    }

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        sv.distribution = .fill
        sv.addArrangedSubview(badgeViewContainer)
        sv.addArrangedSubview(labelsViewContainer)
        return sv
    }()

    //Image and level
    private lazy var badgeImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        let imageViewAspectRatio = NSLayoutConstraint(item: imageView,
                                                      attribute: .height,
                                                      relatedBy: .equal,
                                                      toItem: imageView,
                                                      attribute: .width,
                                                      multiplier: 1.2,
                                                      constant: 0)
        imageView.addConstraint(imageViewAspectRatio)
        return imageView
    }()

    private lazy var badgeBackgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "badge_earned_bg", in: .module, compatibleWith: nil)
        imageView.tintColor = .badgeBackgroundUnearned
        return imageView
    }()

    private lazy var badgeLevelView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.applyRoundedMask(cornerRadious: 15, applyMask: false, corners: .allCorners)
        view.addSubview(badgeLevelLabel)
        return view
    }()

    private lazy var badgeLevelLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.bold, with: 14)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var badgeViewContainer: UIView = {
        let view = UIView(frame: .zero)
        view.addSubview(badgeBackgroundImageView)
        view.addSubview(badgeImageView)
        view.addSubview(badgeLevelView)
        return view
    }()

    //Name & description
    private lazy var badgeNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.textAlignment = .center
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        label.textColor = .foregroundPrimary
        label.numberOfLines = 2
        return label
    }()

    private lazy var badgeDescription: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textAlignment = .center
        label.textColor = .foregroundPrimary
        label.numberOfLines = 0
        return label
    }()

    private lazy var labelsViewContainer: UIView = {
        let view = UIView(frame: .zero)
        view.addSubview(badgeNameLabel)
        view.addSubview(badgeDescription)
        return view
    }()

    //Progress
    private lazy var progressContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.applyRoundedMask(cornerRadious: Styling.cornerRadiusModalPopup, applyMask: false, corners: .allCorners)
        progressStackView.addArrangedSubview(nextLevelLabel)
        progressStackView.addArrangedSubview(nextLevelDescritionLabel)
        progressStripContainer.cover(with: progressView, insets: NSDirectionalEdgeInsets(top: 5, leading: 80, bottom: 5, trailing: 80))
        progressStripContainer.addSubview(progressCounterLabel)
        progressCounterLabel.centerXAnchor.constraint(equalTo: progressStripContainer.centerXAnchor).isActive = true
        progressCounterLabel.centerYAnchor.constraint(equalTo: progressStripContainer.centerYAnchor).isActive = true
        progressStackView.addArrangedSubview(progressStripContainer)
        return view
    }()

    private let progressStripContainer: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()

    private lazy var progressStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.spacing = 15
        return stackView
    }()

    private lazy var nextLevelLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textAlignment = .center
        label.textColor = .foregroundSecondary
        return label
    }()

    private lazy var nextLevelDescritionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .foregroundSecondary
        return label
    }()

    private lazy var progressCounterLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var progressView: ProgressStrip = {
        let pv = ProgressStrip()
        pv.backgroundColor = .backgroundPrimary
        return pv
    }()

    private let labelMargin: CGFloat = 5
    private let labelSideMargin: CGFloat = 16

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
        addSubview(stackView)
        addSubview(progressContainerView)
        progressContainerView.addSubview(progressStackView)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(stackView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(stackView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 10))
        let topConstraint = NSLayoutConstraint(item: stackView,
                                               attribute: .topMargin,
                                               relatedBy: .equal,
                                               toItem: self,
                                               attribute: .topMargin,
                                               multiplier: 1, constant: 70)
        topConstraint.priority = .defaultLow
        constraints.append(topConstraint)
        //Labels
        constraints.append(badgeNameLabel.topAnchor.constraint(equalTo: labelsViewContainer.topAnchor, constant: labelMargin))
        constraints.append(badgeNameLabel.leadingAnchor.constraint(equalTo: labelsViewContainer.leadingAnchor, constant: labelSideMargin))
        constraints.append(badgeNameLabel.trailingAnchor.constraint(equalTo: labelsViewContainer.trailingAnchor, constant: -labelSideMargin))
        constraints.append(badgeDescription.topAnchor.constraint(equalTo: badgeNameLabel.bottomAnchor, constant: 10))
        constraints.append(badgeDescription.leadingAnchor.constraint(equalTo: labelsViewContainer.leadingAnchor, constant: labelSideMargin))
        constraints.append(badgeDescription.trailingAnchor.constraint(equalTo: labelsViewContainer.trailingAnchor, constant: -labelSideMargin))
        constraints.append(badgeDescription.bottomAnchor.constraint(equalTo: labelsViewContainer.bottomAnchor))
        //imageView
        constraints.append(badgeImageView.topAnchor.constraint(equalTo: badgeViewContainer.topAnchor, constant: 5))
        constraints.append(badgeImageView.leadingAnchor.constraint(equalTo: badgeViewContainer.leadingAnchor, constant: 98))
        constraints.append(badgeImageView.trailingAnchor.constraint(equalTo: badgeViewContainer.trailingAnchor, constant: -98))
        constraints.append(badgeImageView.bottomAnchor.constraint(equalTo: badgeViewContainer.bottomAnchor))
        constraints.append(badgeBackgroundImageView.widthAnchor.constraint(equalTo: badgeImageView.widthAnchor))
        constraints.append(badgeBackgroundImageView.heightAnchor.constraint(equalTo: badgeImageView.heightAnchor))
        constraints.append(badgeBackgroundImageView.centerXAnchor.constraint(equalTo: badgeImageView.centerXAnchor))
        constraints.append(badgeBackgroundImageView.centerYAnchor.constraint(equalTo: badgeImageView.centerYAnchor))
        //level container
        constraints.append(badgeLevelView.topAnchor.constraint(equalTo: badgeViewContainer.topAnchor))
        constraints.append(badgeLevelView.centerXAnchor.constraint(equalTo: badgeViewContainer.centerXAnchor))
        constraints.append(badgeLevelLabel.leadingAnchor.constraint(equalTo: badgeLevelView.leadingAnchor, constant: 10))
        constraints.append(badgeLevelLabel.trailingAnchor.constraint(equalTo: badgeLevelView.trailingAnchor, constant: -10))
        constraints.append(badgeLevelLabel.topAnchor.constraint(equalTo: badgeLevelView.topAnchor))
        constraints.append(badgeLevelLabel.bottomAnchor.constraint(equalTo: badgeLevelView.bottomAnchor))

        //progress
        constraints.append(progressContainerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20))
        constraints.append(progressContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))
        constraints.append(progressContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))
        constraints.append(progressContainerView.topAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: 10))
        constraints.append(progressStackView.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 10))
        constraints.append(progressStackView.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -10))
        constraints.append(progressStackView.topAnchor.constraint(equalTo: progressContainerView.topAnchor, constant: 30))
        constraints.append(progressStackView.bottomAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: -30))
        NSLayoutConstraint.activate(constraints)
    }

    private func configureVisuals() {
        guard let viewModel = viewModel, let badgeDetail = viewModel.badgeDetail else { return }
        badgeNameLabel.text = badgeDetail.title
        badgeDescription.text = badgeDetail.subtitle
        badgeLevelLabel.text = viewModel.levelString.uppercased()
        badgeLevelView.backgroundColor = viewModel.levelBackgroundColor
        nextLevelLabel.text = badgeDetail.progression.title
        nextLevelDescritionLabel.text = badgeDetail.progression.description
        progressView.progress = viewModel.currentProgress
        if let progressString = viewModel.progressString {
            progressCounterLabel.text = progressString
        } else {
            progressStackView.removeArrangedSubview(progressStripContainer)
            progressStripContainer.removeFromSuperview()
        }
        let imageUri = traitCollection.userInterfaceStyle == .light ? viewModel.imageLightUri : viewModel.imageDarkUri
        if !imageUri.isEmpty {
            UIImage.loadImage(from: imageUri) { [weak self] url, image, _ in
                guard let weakSelf = self, imageUri == url else { return }
                weakSelf.badgeImageView.image = image
            }
        }
        badgeBackgroundImageView.tintColor = viewModel.badgeBackgroundColor
    }
}
