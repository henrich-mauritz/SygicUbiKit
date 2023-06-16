import UIKit

// MARK: - DashcamVisionTailgatingVehicleInfoType

protocol DashcamVisionTailgatingVehicleInfoType {
    var timeToImpact: Double { get set }
    var carDistance: Double { get set }
    var vehicleFrame: CGRect { get set }
}

// MARK: - DashcamVisionTailgatingVehicleInfo

struct DashcamVisionTailgatingVehicleInfo: DashcamVisionTailgatingVehicleInfoType {
    var timeToImpact: Double
    var carDistance: Double
    var vehicleFrame: CGRect
}

// MARK: - DashcamVisionTailgatingView

class DashcamVisionTailgatingView: UIView {
    private let debugColor: UIColor = .green
    private var hiddenViewWidth: NSLayoutConstraint?
    private var hiddenViewHeight: NSLayoutConstraint?
    private var pulsingViewHeight: NSLayoutConstraint?
    private var keepDistanceBottomConstraint: NSLayoutConstraint?
    private var carFrameLeading: NSLayoutConstraint?
    private var carFrameTop: NSLayoutConstraint?

    private lazy var pulsingImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(image: UIImage(named: "tailgating_new_portrait", in: .module, compatibleWith: nil))
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .negativePrimary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        pulsingViewHeight = imageView.heightAnchor.constraint(equalToConstant: 226)
        pulsingViewHeight?.isActive = true
        return imageView
    }()

    private lazy var tailgatingWarningSign: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tailgatingwarning", in: .module, compatibleWith: nil))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var keepDistanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "vision.tailgatingAlert".localized.uppercased()
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.textColor = .foregroundTertiary
        return label
    }()

    private lazy var carFrameView: UIView = {
        let view = UIView()
        view.layer.borderColor = debugColor.cgColor
        view.layer.borderWidth = 2
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        hiddenViewHeight = view.heightAnchor.constraint(equalToConstant: 0)
        hiddenViewWidth = view.widthAnchor.constraint(equalToConstant: 0)
        return view
    }()

    var tailgatingVehicleInfo: DashcamVisionTailgatingVehicleInfoType? {
        didSet {
            guard let info = tailgatingVehicleInfo else { return }
            layoutIfNeeded()
            hiddenViewWidth?.constant = info.vehicleFrame.width
            hiddenViewHeight?.constant = info.vehicleFrame.height
            carFrameLeading?.constant = info.vehicleFrame.origin.x
            carFrameTop?.constant = info.vehicleFrame.origin.y
            UIView.animate(withDuration: 0.1,
                           delay: 0.0,
                           options: [.curveLinear, .beginFromCurrentState],
                           animations: { [weak self] in
                            self?.layoutIfNeeded()
                           }, completion: nil)
        }
    }

    //MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        addSubview(carFrameView)
        addSubview(tailgatingWarningSign)
        addSubview(pulsingImageView)
        addSubview(keepDistanceLabel)
        var constraints: [NSLayoutConstraint] = []

        carFrameLeading = carFrameView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        carFrameTop = carFrameView.topAnchor.constraint(equalTo: topAnchor, constant: 0)

        constraints.append(pulsingImageView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(pulsingImageView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(pulsingImageView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(keepDistanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))
        constraints.append(keepDistanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))
        constraints.append(carFrameLeading!)
        constraints.append(carFrameTop!)
        constraints.append(tailgatingWarningSign.heightAnchor.constraint(lessThanOrEqualTo: carFrameView.heightAnchor,
                                                                         multiplier: 0.7))
        constraints.append(tailgatingWarningSign.widthAnchor.constraint(lessThanOrEqualTo: carFrameView.widthAnchor,
                                                                        multiplier: 0.7))
        constraints.append(tailgatingWarningSign.centerYAnchor.constraint(equalTo: carFrameView.centerYAnchor))
        constraints.append(tailgatingWarningSign.centerXAnchor.constraint(equalTo: carFrameView.centerXAnchor))
        constraints.append(keepDistanceLabel.bottomAnchor.constraint(equalTo: pulsingImageView.bottomAnchor, constant: -40))
        hiddenViewHeight?.isActive = true
        hiddenViewWidth?.isActive = true
        NSLayoutConstraint.activate(constraints)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if UIWindow.isLandscape {
            pulsingViewHeight?.constant = 160
            pulsingImageView.image = UIImage(named: "tailgating_new_landscape", in: .module, compatibleWith: nil)
        } else {
            pulsingViewHeight?.constant = 226
            pulsingImageView.image = UIImage(named: "tailgating_new_portrait", in: .module, compatibleWith: nil)
        }
    }
}
