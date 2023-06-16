import UIKit

public class GradientDrawView: UIView {
    public enum Direction {
        case leftToRight
        case rightToLeft
        case bottomToTop
        case topToBottom
    }

    public var colors: [UIColor] = [UIColor.backgroundOverlay.withAlphaComponent(0), .backgroundOverlay]
    public var locations: [CGFloat] = [0, 1]
    public var startPoint: CGPoint = .zero
    public var endPoint: CGPoint?
    private var direction: Direction?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    public init(frame: CGRect, direction: Direction? = nil) {
        super.init(frame: frame)
        self.direction = direction
        backgroundColor = .clear
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    override public func draw(_ rect: CGRect) {
        let gradientColors = colors.map { $0.cgColor }
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let direction = self.direction {
            var sp: CGPoint = .zero
            var ep: CGPoint = .zero
            switch direction {
            case .leftToRight:
                ep = CGPoint(x: rect.width, y: 0)
            case .rightToLeft:
                sp = CGPoint(x: rect.width, y: 0)
            case .topToBottom:
                ep = CGPoint(x: 0, y: rect.height)
            case .bottomToTop:
                sp = CGPoint(x: 0, y: rect.height)
            }
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors as CFArray, locations: locations) else { return }
            context?.drawLinearGradient(gradient, start: sp, end: ep, options: CGGradientDrawingOptions(rawValue: 0))
        } else { //giving support to old implementation
            let endPoint: CGPoint = self.endPoint ?? CGPoint(x: 0, y: rect.size.height)
            guard gradientColors.count > 0,
                  let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors as CFArray, locations: locations),
                  !startPoint.equalTo(endPoint) else { return }
            context?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        }
    }
}
