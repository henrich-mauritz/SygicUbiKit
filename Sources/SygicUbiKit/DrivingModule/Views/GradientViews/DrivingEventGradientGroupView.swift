import UIKit

class DrivingEventGradientGroupView: UIView {
    enum EventGradientSide {
        case left, right, top, bottom
    }

    private let prefix: String
    private let animationTime: Double = 0.25

    public let side: EventGradientSide

    private lazy var lowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "\(prefix)_low_portrait", in: .module, compatibleWith: nil))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0.33
        imageView.tintColor = .negativePrimary
        imageView.isHidden = true
        return imageView
    }()

    private lazy var midImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "\(prefix)_mid_portrait", in: .module, compatibleWith: nil))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0.33
        imageView.tintColor = .negativePrimary
        imageView.isHidden = true
        return imageView
    }()

    private lazy var highImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "\(prefix)_high_portrait", in: .module, compatibleWith: nil))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0.34
        imageView.tintColor = .negativePrimary
        imageView.isHidden = true
        return imageView
    }()

    public var intensity: Int = 0 {
        willSet {
            switch newValue {
            case 1:
                animateOut(gradientImageView: highImageView)
                animateOut(gradientImageView: midImageView)
                animateIn(gradientImageView: lowImageView)
            case 2:
                animateOut(gradientImageView: highImageView)
                animateIn(gradientImageView: lowImageView)
                animateIn(gradientImageView: midImageView)
            case 3:
                animateIn(gradientImageView: lowImageView)
                animateIn(gradientImageView: midImageView)
                animateIn(gradientImageView: highImageView)
            default:
                animateOut(gradientImageView: highImageView)
                animateOut(gradientImageView: midImageView)
                animateOut(gradientImageView: lowImageView)
            }
            //setNeedsDisplay()
        }
    }

    init(with prefix: String, side: EventGradientSide) {
        self.prefix = prefix
        self.side = side
        super.init(frame: .zero)
        setupLayout()
    }

    func updateImage(with prefix: String, pofix: String) {
        lowImageView.image = UIImage(named: "\(prefix)_low_\(pofix)", in: .module, compatibleWith: nil)
        midImageView.image = UIImage(named: "\(prefix)_mid_\(pofix)", in: .module, compatibleWith: nil)
        highImageView.image = UIImage(named: "\(prefix)_high_\(pofix)", in: .module, compatibleWith: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        cover(with: highImageView, toSafeArea: false)
        cover(with: midImageView, toSafeArea: false)
        cover(with: lowImageView, toSafeArea: false)
    }

    private func animateIn(gradientImageView: UIImageView) {
        if !gradientImageView.isHidden {
            return
        }

        var subtype: CATransitionSubtype?
        switch self.side {
        case .left:
            subtype = .fromLeft
        case .bottom:
            subtype = .fromTop
        case .right:
            subtype = .fromRight
        case .top:
            subtype = .fromBottom
        }

        let transition = CATransition()
        transition.duration = animationTime
        transition.type = .moveIn
        transition.subtype = subtype
        gradientImageView.layer.add(transition, forKey: "animateInTransition")
        gradientImageView.isHidden = false
    }

    private func animateOut(gradientImageView: UIImageView) {
        if gradientImageView.isHidden {
            return
        }
        UIView.transition(with: gradientImageView, duration: animationTime,
                          options: [.transitionCrossDissolve, .beginFromCurrentState],
                          animations: {
            gradientImageView.isHidden = true
                      })
    }
}
