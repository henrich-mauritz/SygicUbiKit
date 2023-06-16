import UIKit

class AboutYourScoreTableViewCell: UITableViewCell {
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        return label
    }()

    public lazy var disclosureIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .actionPrimary
        imageView.image = UIImage(named: "disclosureIndicator", in: .module, compatibleWith: nil)
        return imageView
    }()

    public let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        return view
    }()

    private let height: CGFloat = 55

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        selectedBackgroundView = view
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {
        backgroundColor = .clear
        imageView?.removeFromSuperview()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        disclosureIcon.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(disclosureIcon)
        addSubview(separatorView)
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentView.heightAnchor.constraint(equalToConstant: height))
        constraints.append(disclosureIcon.widthAnchor.constraint(equalToConstant: 12))
        constraints.append(disclosureIcon.heightAnchor.constraint(equalToConstant: 11))
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        constraints.append(titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(disclosureIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin))
        constraints.append(disclosureIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(separatorView.heightAnchor.constraint(equalToConstant: 0.5))
        constraints.append(separatorView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin))
        constraints.append(separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin))
        NSLayoutConstraint.activate(constraints)
        contentView.cover(with: bgView, insets: .zero)
        contentView.sendSubviewToBack(bgView)
    }

    let bgView: UIView = {
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = .backgroundPrimary
        return bgView
    }()

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        //becaise of setting a bg view we need to override this to make the highlithing visual again
        super.setHighlighted(highlighted, animated: animated)
        //bgView.backgroundColor = highlighted ? .backgroundSecondary : .backgroundPrimary
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.font = UIFont.stylingFont(.regular, with: 16)
    }

    func update(with info: DriveScoreInfoType) {
        titleLabel.text = info.title
        if info.showArrow {
            toggleState(expanded: info.isExpanded)
        } else {
            titleLabel.font = UIFont.stylingFont(.bold, with: 16)
        }

        selectedBackgroundView?.isHidden = !info.showArrow
        separatorView.isHidden = !info.showArrow
        disclosureIcon.isHidden = !info.showArrow
    }

    func toggleState(expanded: Bool, animated: Bool = false) {
        var font = UIFont.stylingFont(.regular, with: 16)
        var separatorHidden = false
        if expanded {
           font = UIFont.stylingFont(.bold, with: 16)
            separatorHidden = true
        }
        titleLabel.font = font
        separatorView.isHidden = separatorHidden

        if animated {
            UIView.animate(withDuration: 0.2) {
                self.setArrowPosition(expanded: expanded)
            }
        } else {
            self.setArrowPosition(expanded: expanded)
        }
    }

    /// rotate the discluosure by angle
    /// - Parameter angle: the angle in grads
    func setArrowPosition(expanded: Bool) {
        var angle: Double = 0.0
        if expanded {
            angle = 90.0
        }
        disclosureIcon.transform = CGAffineTransform(rotationAngle: CGFloat(Double.deg2rad(angle)))
    }
}
