import UIKit

// MARK: - VPVehicleSelectorControl

public class VPVehicleSelectorControl: UIControl {
    public enum Style {
        case bubble
        case plain
    }

    public enum Size {
        case big
        case small
    }

    public let style: Style
    public let controlSize: VPVehicleSelectorControl.Size
    public var widthLayoutConstraint: NSLayoutConstraint?

    private var contentView: VPVehicleSelectorType?

    public init(with style: Style = .bubble,
                controlSize size: VPVehicleSelectorControl.Size = .big,
                icon: UIImage?, title: String) {
        self.style = style
        self.controlSize = size
        super.init(frame: .zero)
        setupInnerComponents()
        contentView?.imageIcon = icon
        contentView?.vehicleName = title
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInnerComponents() {
        let bubbleSelector = VPBubbleVehicleSelectorView(with: self.controlSize)
        if style == .plain {
            bubbleSelector.configureForPlainStyle()
        }
        contentView = bubbleSelector
    }

    private func setupLayout() {
        guard let contentView = contentView else {
            return
        }
        cover(with: contentView)
        widthLayoutConstraint = widthAnchor.constraint(greaterThanOrEqualToConstant: 87)
        widthLayoutConstraint!.isActive = true
    }

    public func configure(with icon: UIImage?, title: String?) {
        contentView?.imageIcon = icon
        contentView?.vehicleName = title
    }

    public func configure(with vehicle: VehicleProfileType) {
        configure(with: vehicle.vehicleType.icon, title: vehicle.name.uppercased())
    }

    public func configureForPlainStyle(with arrowPositon: VPBubbleVehicleSelectorView.ArrowPostion = .right) {
        contentView?.configureForPlainStyle(with: arrowPositon)
    }
}

public extension VPVehicleSelectorControl {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = Styling.highlightedStateAlpha
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            if bounds.contains(location) {
                self.sendActions(for: UIControl.Event.touchUpInside)
            }
            alpha = 1

        } else {
            alpha = 1
        }
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1
        super.touchesCancelled(touches, with: event)
    }
}
