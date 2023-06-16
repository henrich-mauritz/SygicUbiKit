import UIKit

class DrivingEventsGradientView: UIView {
    enum EventGradientGroup {
        case left, right, top, bottom
    }

    private let portraitVerticalWitdh: CGFloat = 116
    private let portraitHorizontalHeight: CGFloat = 135
    private let landscapeVerticalWidth: CGFloat = 135
    private let landscapeHorizonalHeight: CGFloat = 116

    private lazy var leftGroup: DrivingEventGradientGroupView = {
        let group = DrivingEventGradientGroupView(with: "left", side: .left)
        group.translatesAutoresizingMaskIntoConstraints = false
        return group
    }()

    private lazy var rightGroup: DrivingEventGradientGroupView = {
        let group = DrivingEventGradientGroupView(with: "right", side: .right)
        group.translatesAutoresizingMaskIntoConstraints = false
        return group
    }()

    private lazy var topGroup: DrivingEventGradientGroupView = {
        let group = DrivingEventGradientGroupView(with: "top", side: .top)
        group.translatesAutoresizingMaskIntoConstraints = false
        return group
    }()

    private lazy var bottomGroup: DrivingEventGradientGroupView = {
        let group = DrivingEventGradientGroupView(with: "bottom", side: .bottom)
        group.translatesAutoresizingMaskIntoConstraints = false
        return group
    }()

    private var leftGroupWidthConstraint: NSLayoutConstraint?
    private var rightGroupWidthConstraint: NSLayoutConstraint?
    private var topGroupHeightConstraint: NSLayoutConstraint?
    private var bottomGroupHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        leftGroupWidthConstraint = leftGroup.widthAnchor.constraint(equalToConstant: portraitVerticalWitdh)
        rightGroupWidthConstraint = rightGroup.widthAnchor.constraint(equalToConstant: portraitVerticalWitdh)
        topGroupHeightConstraint = topGroup.heightAnchor.constraint(equalToConstant: portraitHorizontalHeight)
        bottomGroupHeightConstraint = bottomGroup.heightAnchor.constraint(equalToConstant: portraitHorizontalHeight)

        addSubview(leftGroup)
        addSubview(bottomGroup)
        addSubview(rightGroup)
        addSubview(topGroup)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(leftGroup.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(leftGroup.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(leftGroup.bottomAnchor.constraint(equalTo: bottomAnchor))

        constraints.append(bottomGroup.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(bottomGroup.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(bottomGroup.trailingAnchor.constraint(equalTo: trailingAnchor))

        constraints.append(rightGroup.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(rightGroup.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(rightGroup.bottomAnchor.constraint(equalTo: bottomAnchor))

        constraints.append(topGroup.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(topGroup.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(topGroup.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(leftGroupWidthConstraint!)
        constraints.append(rightGroupWidthConstraint!)
        constraints.append(topGroupHeightConstraint!)
        constraints.append(bottomGroupHeightConstraint!)
        NSLayoutConstraint.activate(constraints)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        var pofixString: String?
        if UIDevice.current.orientation.isLandscape {
            leftGroupWidthConstraint?.constant = portraitHorizontalHeight
            rightGroupWidthConstraint?.constant = portraitHorizontalHeight
            topGroupHeightConstraint?.constant = portraitVerticalWitdh
            bottomGroupHeightConstraint?.constant = portraitVerticalWitdh
            pofixString = "landscape"
        } else if UIDevice.current.orientation.isPortrait {
            leftGroupWidthConstraint?.constant = portraitVerticalWitdh
            rightGroupWidthConstraint?.constant = portraitVerticalWitdh
            topGroupHeightConstraint?.constant = portraitHorizontalHeight
            bottomGroupHeightConstraint?.constant = portraitHorizontalHeight
            pofixString = "portrait"
        }
        guard let pofix = pofixString else { return }
        leftGroup.updateImage(with: "left", pofix: pofix)
        bottomGroup.updateImage(with: "bottom", pofix: pofix)
        rightGroup.updateImage(with: "right", pofix: pofix)
        topGroup.updateImage(with: "top", pofix: pofix)
    }

    /// This is the function to control gradients, just call the function with the group you want to controll and intensity value
    /// - Parameter group: group you want to change
    /// - Parameter intensity: intensity level must be 0<=intensity<=3
    public func changeGradientIntensity(group: EventGradientGroup, intensity: Int) {
        if intensity < 0 || intensity > 3 {
            return
        }
        switch group {
        case .left:
            self.leftGroup.intensity = intensity
        case .right:
            self.rightGroup.intensity = intensity
        case .top:
            self.topGroup.intensity = intensity
        case .bottom:
            self.bottomGroup.intensity = intensity
        }
    }
}
