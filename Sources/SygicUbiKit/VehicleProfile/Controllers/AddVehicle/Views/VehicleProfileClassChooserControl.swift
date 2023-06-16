import UIKit

// MARK: - VehicleProfileClassChooserControl

class VehicleProfileClassChooserControl: UIControl {
    override var isSelected: Bool {
        willSet {
            var bgColor: UIColor
            var newTintColor: UIColor
            if newValue == true {
                bgColor = .actionPrimary
                newTintColor = .white
            } else {
                bgColor = .backgroundSecondary
                newTintColor = .foregroundPrimary.withAlphaComponent(0.5)
            }

            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.containerView.backgroundColor = bgColor
                self.titleLabel.textColor = newTintColor
                self.icon.tintColor = newTintColor
                self.alpha = 1
            }
        }
    }

    private lazy var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.layer.cornerRadius = Styling.cornerRadiusModalPopup
        view.layer.masksToBounds = true
        view.backgroundColor = .backgroundSecondary
        return view
    }()

    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .foregroundPrimary.withAlphaComponent(0.5)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textAlignment = .center
        label.textColor = .foregroundPrimary.withAlphaComponent(0.5)
        label.numberOfLines = 2
        return label
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 5
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(VehicleProfileClassChooserControl.tap))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        cover(with: containerView)
        let iconContainerView = UIView()
        iconContainerView.addSubview(icon)
        containerView.cover(with: stackView, insets: NSDirectionalEdgeInsets(top: 24, leading: 0, bottom: 16, trailing: 0))
        stackView.addArrangedSubview(iconContainerView)
        stackView.addArrangedSubview(titleLabel)
        //stackView.addArrangedSubview(UIView()) //emtpy subview at the botom

        var constraints: [NSLayoutConstraint] = []
        constraints.append(icon.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor))
        constraints.append(icon.topAnchor.constraint(equalTo: iconContainerView.topAnchor))
        constraints.append(icon.bottomAnchor.constraint(equalTo: iconContainerView.bottomAnchor))
        constraints.append(widthAnchor.constraint(equalToConstant: 130))
        constraints.append(heightAnchor.constraint(equalTo: widthAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    public func configure(with text: String, icon: UIImage?) {
        self.icon.image = icon
        self.titleLabel.text = text
    }

    @objc
private func setSelectedUI() {
        isSelected = !isSelected
    }

    @objc
private func tap() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
}

//MARK: - User Interaction Feedback

extension VehicleProfileClassChooserControl {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = Styling.highlightedStateAlpha
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            if bounds.contains(location) {
                isSelected = true
            } else {
                alpha = 1
            }
        } else {
            alpha = 1
        }
        super.touchesEnded(touches, with: event)
    }
}
