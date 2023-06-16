import UIKit

// MARK: - AddVehicleStepView

class AddVehicleStepView: UIView {
    lazy var firstStepView: VehicleStepView = {
        let view = VehicleStepView(frame: .zero)
        return view
    }()

    lazy var secondStepView: VehicleStepView = {
        let view = VehicleStepView(frame: .zero)
        return view
    }()

    lazy var lineSegmentView: UIView = {
        let view = UIView(frame: .zero)
        view.widthAnchor.constraint(equalToConstant: 64).isActive = true
        view.layer.borderColor = Styling.backgroundSecondary.cgColor
        view.layer.borderWidth = 2
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var lineSegmentContainer: UIView = {
        let view = UIView()
        view.addSubview(lineSegmentView)
        lineSegmentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSegmentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSegmentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [firstStepView, lineSegmentContainer, secondStepView])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 5
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        cover(with: stackView)
    }

    public func highLightDivider(value: Bool) {
        if value {
            lineSegmentView.layer.borderColor = Styling.actionPrimary.cgColor
        } else {
            lineSegmentView.layer.borderColor = Styling.backgroundSecondary.cgColor
        }
    }
}

// MARK: - VehicleStepView

class VehicleStepView: UIView {
    enum VehicleStepViewState {
        case highLighted
        case completed
        case incomplete
    }

    var state: VehicleStepViewState = .incomplete {
        didSet {
            var color: UIColor
            var fill: Bool = false
            switch state {
            case .highLighted:
                color = .actionPrimary
                completedImageView.isHidden = true
                stepLabel.isHidden = false
            case .completed:
                color = .actionPrimary
                completedImageView.isHidden = false
                stepLabel.isHidden = true
                fill = true
            case .incomplete:
                color = .backgroundSecondary
                completedImageView.isHidden = true
                stepLabel.isHidden = false
            }
            stepLabel.textColor = color
            layer.borderColor = color.cgColor
            if fill {
                backgroundColor = color
            } else {
                backgroundColor = .clear
            }
        }
    }

     lazy var stepLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.semibold, with: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var completedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stepDoneImage", in: .module, compatibleWith: nil)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        cover(with: stepLabel, insets: NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        layer.cornerRadius = 15
        layer.borderWidth = 2
        cover(with: completedImageView)
    }
}
