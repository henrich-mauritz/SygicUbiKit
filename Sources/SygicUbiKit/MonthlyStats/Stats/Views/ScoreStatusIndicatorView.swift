import Foundation
import UIKit

class ScoreStatusIndicatorView: UIView {
    let size: CGFloat = 30

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .foregroundTertiary
        imageView.isHidden = true
        return imageView
    }()

    let noChangeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .foregroundTertiary
        view.layer.cornerRadius = 2.5
        view.widthAnchor.constraint(equalToConstant: 5).isActive = true
        view.heightAnchor.constraint(equalToConstant: 5).isActive = true
        return view
    }()

    lazy var topImage: UIImage? = { UIImage(named: "iconsTriglavBadges", in: .module, compatibleWith: nil) }()
    lazy var arrowImage: UIImage? = { UIImage(named: "iconsTriglavArrowStats", in: .module, compatibleWith: nil) }()
    lazy var doubleArrowImage: UIImage? = { UIImage(named: "iconsTriglavArrowStatsSignificant", in: .module, compatibleWith: nil) }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = size / 2.0
        addSubview(noChangeView)
        addSubview(imageView)
        var constrains: [NSLayoutConstraint] = []
        constrains.append(widthAnchor.constraint(equalToConstant: size))
                          constrains.append(heightAnchor.constraint(equalToConstant: size))
        constrains.append(noChangeView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constrains.append(noChangeView.centerYAnchor.constraint(equalTo: centerYAnchor))
        constrains.append(imageView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constrains.append(imageView.centerYAnchor.constraint(equalTo: centerYAnchor))
        NSLayoutConstraint.activate(constrains)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with state: ReportScoreMonthComparision?) {
        guard let state = state else {
            return
        }
        backgroundColor = state.color
        imageView.transform = CGAffineTransform.identity
        imageView.isHidden = false
        noChangeView.isHidden = true
        switch state {
        case .best:
            imageView.image = topImage
        case .decreased:
            imageView.image = arrowImage
        case .decreasedSignificantly:
            imageView.image = doubleArrowImage
        case .increased:
            imageView.image = arrowImage
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        case .increasedSignificantly:
            imageView.image = doubleArrowImage
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        default:
            imageView.isHidden = true
            noChangeView.isHidden = false
        }
    }
}
