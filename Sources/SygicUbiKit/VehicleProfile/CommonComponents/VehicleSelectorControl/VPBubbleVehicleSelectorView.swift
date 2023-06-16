import UIKit

public class VPBubbleVehicleSelectorView: UIView, VPVehicleSelectorType {
    public enum ArrowPostion {
        case right
        case left
    }

    private let widthHeight: CGFloat = 40

    var imageIcon: UIImage? {
        didSet {
            //imageView.image = imageIcon
        }
    }

    var vehicleName: String? {
        didSet {
            titleLabel.text = vehicleName
        }
    }

    var hasChevrom: Bool = true

    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.heightAnchor.constraint(equalToConstant: iconWidthHeigth).isActive = true
        iv.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        iv.tintColor = .foregroundPrimary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel.stylingLabel(with: titleFontType, size: 14, textColor: .foregroundPrimary)
        label.setContentHuggingPriority(UILayoutPriority(750), for: .horizontal)
        return label
    }()

    private lazy var chevronIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "carSelectorControlArrow", in: .module, compatibleWith: nil))
        imageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        imageView.tintColor = .foregroundPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var chevronViewContainer: UIView = {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: widthHeight).isActive = true
        imageView.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        return view
    }()

    lazy var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: bubbleHeight).isActive = true
        view.layer.cornerRadius = controlSize == .big ? Styling.cornerRadius : Styling.cornerRadius / 2
        return view
    }()

    lazy var verticalDivider: UIView = {
       let view = UIView()
        view.backgroundColor = .backgroundPrimary
        view.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()

    private lazy var innerStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .fill
        return stackView
    }()

    private var iconWidthHeigth: CGFloat {
        if controlSize == .big {
            return 16
        } else {
            return 12
        }
    }

    private var bubbleHeight: CGFloat {
        if controlSize == .big {
            return widthHeight
        } else {
            return 30
        }
    }

    private var titleFontType: UIFont.FontType {
        if controlSize == .big {
            return .bold
        } else {
            return .regular
        }
    }

    private var controlSize: VPVehicleSelectorControl.Size

//MARK: - lifeCycle

    init(with controlSize: VPVehicleSelectorControl.Size) {
        self.controlSize = controlSize
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        cover(with: bubbleView)
        bubbleView.cover(with: innerStackView, insets: NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
        chevronIcon.translatesAutoresizingMaskIntoConstraints = false
        verticalDivider.translatesAutoresizingMaskIntoConstraints = false
        chevronViewContainer.addSubview(chevronIcon)
        chevronViewContainer.addSubview(verticalDivider)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(chevronIcon.centerXAnchor.constraint(equalTo: chevronViewContainer.centerXAnchor))
        constraints.append(chevronIcon.centerYAnchor.constraint(equalTo: chevronViewContainer.centerYAnchor))
        constraints.append(verticalDivider.leadingAnchor.constraint(equalTo: chevronViewContainer.leadingAnchor))
        constraints.append(verticalDivider.topAnchor.constraint(equalTo: chevronViewContainer.topAnchor))
        constraints.append(verticalDivider.bottomAnchor.constraint(equalTo: chevronViewContainer.bottomAnchor))
        //innerStackView.addArrangedSubview(imageView)
        let labelViewContainer = UIView()
        labelViewContainer.cover(with: titleLabel, insets: NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
        innerStackView.addArrangedSubview(labelViewContainer)
        innerStackView.addArrangedSubview(chevronViewContainer)
        NSLayoutConstraint.activate(constraints)
    }

    func configureForPlainStyle(with arrowPositon: ArrowPostion = .right) {
//        if controlSize == .small {
//            imageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
//        }
        bubbleView.backgroundColor = .clear
        innerStackView.removeArrangedSubview(chevronViewContainer)
        chevronViewContainer.removeFromSuperview()
        switch arrowPositon {
        case .right:
            innerStackView.addArrangedSubview(chevronViewContainer)
        case .left:
            chevronIcon.removeFromSuperview()
            innerStackView.insertArrangedSubview(chevronIcon, at: 0)
        }
    }
}
