import UIKit

public class DrivingFloatingBar: UIView {
    /// Bar style for the driving banner, Long wil display the bar with icon and title
    /// Short will display only the icon
    public enum BarStyle {
        case long
        case short
    }

    var action: (() -> ())?

    public class func height(for style: BarStyle) -> CGFloat {
        switch style {
        case .long:
            return LongDrivingFloatingBar.barHeight
        case .short:
            return ShortDrivingFloatingBar.barHeight
        }
    }

    public var imageView: UIImageView = UIImageView()

    /// Factory to return the appropiate bar
    /// - Parameter style: style of the bar
    public class func DrivingBar(with style: BarStyle, tapAction: @escaping () -> ()) -> DrivingFloatingBar {
        switch style {
        case .long:
            return LongDrivingFloatingBar(tapAction: tapAction)
        case .short:
            return ShortDrivingFloatingBar(tapAction: tapAction)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(tapAction: @escaping () -> ()) {
        super.init(frame: .zero)
        action = tapAction
    }

    public func resetUI() {
        imageView.removeFromSuperview()
    }

    open func setVehicleIcon(with image: UIImage?) {
        imageView.image = image
    }
    
    open func pulseAnimation(enable: Bool) {
        //override in childrens
    }
    
    open func resumeAnimation() {
        //override in childrens
    }
}
