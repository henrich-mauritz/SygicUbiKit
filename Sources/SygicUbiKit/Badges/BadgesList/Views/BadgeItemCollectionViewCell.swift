import Foundation
import UIKit

open class BadgeItemCollectionViewCell: UICollectionViewCell, BadgeItemCellConfigurable {
    public lazy var badgeBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "badge_earned_bg", in: .module, compatibleWith: nil)
        imageView.tintColor = .badgeBackgroundUnearned
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    public lazy var badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var badgeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textColor = .foregroundPrimary
        label.numberOfLines = 2
        label.textAlignment = .center
        label.contentMode = .top
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var currentLevelView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: TOP_PADDING * 2).isActive = true
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        view.applyRoundedMask(cornerRadious: 10, applyMask: false, corners: .allCorners)
        return view
    }()

    private lazy var currentLevelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var innerDot: UIView = {
        let innerView = UIView(frame: .zero)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        return innerView
    }()

    private lazy var newDotIndicator: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundPrimary
        view.isHidden = true
        view.addSubview(innerDot)
        innerDot.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
        innerDot.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6).isActive = true
        innerDot.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        innerDot.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        innerDot.backgroundColor = .actionPrimary
        return view
    }()

    private var badgeImageUri: String?
    private var redDotTopContraint: NSLayoutConstraint?
    private var redDotLeadingConstraint: NSLayoutConstraint?
    private var TOP_PADDING: CGFloat { 10 }
    open var MARGIN: CGFloat { 20 }
    open var PADDING: CGFloat { 10 }
    open var BG_ASPECT_RATIO: CGFloat { 0.87 }

    override public var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? 0.8 : 1.0
        }
    }

    //MARK: - LifeCycle

    override public init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var reuseIdentifier: String? { return BadgeItemCollectionViewCell.cellIdentifier }

    override public func prepareForReuse() {
        badgeImageView.image = nil
        badgeImageUri = nil
        badgeTitleLabel.text = ""
        currentLevelLabel.text = ""
        newDotIndicator.isHidden = true
        super.prepareForReuse()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutRedDot()
    }

    public func configure(with item: BadgeItemType) {
        var topText = "badges.earnIt".localized
        if item.earned {
            topText = String(format: "badges.levelX".localized, item.currentLevel)
            currentLevelView.backgroundColor = .positivePrimary
        } else {
            currentLevelView.backgroundColor = .negativeSecondary
        }

        let imageURI: String = traitCollection.userInterfaceStyle == .light ? item.imageLightUri : item.imageDarkUri
        badgeImageUri = imageURI
        if !imageURI.isEmpty {
            UIImage.loadImage(from: imageURI) { [weak self] uri, image, _ in
                guard let weakSelf = self, weakSelf.badgeImageUri == uri else { return }
                weakSelf.badgeImageView.image = image
            }
        }
        badgeBackgroundImageView.tintColor = item.earned ? .badgeBackgroundEarned : .badgeBackgroundUnearned
        currentLevelLabel.text = topText.uppercased()
        badgeTitleLabel.text = item.title

        if item.earned {
            if let storedLevel = UserDefaults.standard.value(forKey: "badge_\(item.id)_level") as? Int, storedLevel < item.currentLevel {
                newDotIndicator.isHidden = false
            } else {
                newDotIndicator.isHidden = true
            }
        } else {
            newDotIndicator.isHidden = true
        }
        layoutIfNeeded()
    }

    /// RedDot must be configurea fter all is layout because it has to match its origin in the end of the drawable part of the imageView
    private func layoutRedDot() {
        let drawableRect = badgeBackgroundImageView.calculateRectOfImageInImageView()
        redDotTopContraint?.constant = drawableRect.origin.y - 3
        redDotLeadingConstraint?.constant = drawableRect.maxX - newDotIndicator.bounds.width + 2
        newDotIndicator.applyRoundedMask(cornerRadious: newDotIndicator.bounds.width / 2, applyMask: false, corners: .allCorners)
        innerDot.applyRoundedMask(cornerRadious: innerDot.bounds.width / 2, applyMask: false, corners: .allCorners)
    }

    private func setupLayout() {
        currentLevelView.addSubview(currentLevelLabel)
        contentView.addSubview(badgeBackgroundImageView)
        contentView.addSubview(badgeImageView)
        contentView.addSubview(badgeTitleLabel)
        contentView.addSubview(currentLevelView)
        contentView.addSubview(newDotIndicator)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(currentLevelLabel.leadingAnchor.constraint(equalTo: currentLevelView.leadingAnchor, constant: PADDING))
        constraints.append(currentLevelLabel.trailingAnchor.constraint(equalTo: currentLevelView.trailingAnchor, constant: -PADDING))
        constraints.append(currentLevelLabel.centerYAnchor.constraint(equalTo: currentLevelView.centerYAnchor))
        constraints.append(badgeBackgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: TOP_PADDING))
        constraints.append(badgeBackgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: MARGIN))
        constraints.append(badgeBackgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -MARGIN))
        constraints.append(badgeImageView.widthAnchor.constraint(equalTo: badgeBackgroundImageView.widthAnchor))
        constraints.append(badgeImageView.heightAnchor.constraint(equalTo: badgeBackgroundImageView.heightAnchor))
        constraints.append(badgeImageView.centerYAnchor.constraint(equalTo: badgeBackgroundImageView.centerYAnchor))
        constraints.append(badgeImageView.centerXAnchor.constraint(equalTo: badgeBackgroundImageView.centerXAnchor))
        constraints.append(badgeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PADDING))
        constraints.append(badgeTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PADDING))
        constraints.append(badgeTitleLabel.topAnchor.constraint(equalTo: badgeBackgroundImageView.bottomAnchor, constant: PADDING))
        constraints.append(currentLevelView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
        constraints.append(currentLevelView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0))
        redDotLeadingConstraint = NSLayoutConstraint(item: newDotIndicator,
                                                     attribute: .leading,
                                                     relatedBy: .equal,
                                                     toItem: contentView,
                                                     attribute: .leading,
                                                     multiplier: 1, constant: 0)
        redDotTopContraint = NSLayoutConstraint(item: newDotIndicator,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .top,
                                                multiplier: 1,
                                                constant: 0)
        constraints.append(redDotLeadingConstraint!)
        constraints.append(redDotTopContraint!)
        NSLayoutConstraint.activate(constraints)
        badgeImageView.addConstraint(NSLayoutConstraint(item: badgeImageView,
                                                        attribute: .height,
                                                        relatedBy: .equal,
                                                        toItem: badgeImageView,
                                                        attribute: .width,
                                                        multiplier: BG_ASPECT_RATIO,
                                                        constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: newDotIndicator,
                                                     attribute: .width,
                                                     relatedBy: .equal,
                                                     toItem: badgeImageView,
                                                     attribute: .width,
                                                     multiplier: 0.1,
                                                     constant: 0))
        newDotIndicator.addConstraint(NSLayoutConstraint(item: newDotIndicator,
                                                         attribute: .height,
                                                         relatedBy: .equal,
                                                         toItem: newDotIndicator,
                                                         attribute: .width,
                                                         multiplier: 1,
                                                         constant: 0))
    }
}
