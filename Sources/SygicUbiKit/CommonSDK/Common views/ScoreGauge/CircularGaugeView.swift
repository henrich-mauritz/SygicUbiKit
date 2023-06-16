import UIKit

// MARK: - GaugeScoreDataType

//MARK: - DashboardGaugeScoreDataType

public protocol GaugeScoreDataType: ProgressColoring {
    var overallScore: Double { get set }
    var overallScoreRequirement: Double { get set }
    var title: String { get set }
    var overallScoreStringValue: String? { get }
}

public extension GaugeScoreDataType {
    var overallScoreStringValue: String? { nil }
}

// MARK: - CircularGaugeView

//MARK: - CircularGaugeView

/// View that display the score in a visual semi cirlce way/
public class CircularGaugeView: UIView {
    private lazy var scoreValueLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.thin, with: 80)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.text = ""
        label.textAlignment = .center
        label.textColor = .foregroundPrimary
        return label
    }()

    private lazy var subttileLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.text = ""
        return label
    }()

    private lazy var semiCricleView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private lazy var knob: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.backgroundSecondary.cgColor
        layer.lineCap = .round
        layer.lineWidth = shapeStroke
        return layer
    }()

    private lazy var track: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineWidth = shapeStroke
        return layer
    }()

    private let shapeStroke: CGFloat = 22
    private var currentAngle: CGFloat = 180

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        backgroundColor = .clear
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        //Wehave to add the shape layyer after layout is completed
        configure(shape: knob, on: semiCricleView, with: 360)
        configure(shape: track, on: semiCricleView, with: Double(currentAngle), finalizeStroke: false)
    }

    private func configure(shape: CAShapeLayer, on view: UIView, with angle: Double, finalizeStroke: Bool = true) {
        shape.removeFromSuperlayer()
        shape.frame = view.bounds
        shape.path = UIBezierPath(arcCenter: CGPoint(x: semiCricleView.bounds.midX, y: semiCricleView.bounds.maxY - shapeStroke / 2),
                                  radius: view.bounds.width / 2 - shapeStroke / 2,
                                  startAngle: CGFloat(Double.deg2rad(180)), endAngle: CGFloat(Double.deg2rad(angle)), clockwise: true).cgPath
        shape.strokeStart = 0
        shape.strokeEnd = 0
        view.layer.addSublayer(shape)
        if finalizeStroke {
            shape.strokeEnd = 1
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setupLayout() {
        cover(with: semiCricleView, insets: .zero)
        addSubview(scoreValueLabel)
        addSubview(subttileLabel)
        let leadingConstraint = scoreValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 90)
        let trailingConstraint = scoreValueLabel.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -90)
        leadingConstraint.priority = .init(rawValue: 999.0)
        trailingConstraint.priority = .init(rawValue: 999.0)
        NSLayoutConstraint.activate([
            subttileLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            scoreValueLabel.bottomAnchor.constraint(equalTo: subttileLabel.topAnchor, constant: -5),
            subttileLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            scoreValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            leadingConstraint,
            trailingConstraint,
        ])
    }

    public func update(gaugeScore scoreType: GaugeScoreDataType, animate: Bool = false) {
        if scoreType.overallScoreStringValue != nil {
            scoreValueLabel.text = scoreType.overallScoreStringValue
        } else {
            scoreValueLabel.text = Format.scoreFormatted(value: scoreType.overallScore)
        }
        subttileLabel.text = scoreType.title

        let valueAngle = ((180 / 100) * Double(scoreType.overallScore)) + 180.0
        configure(shape: track, on: semiCricleView, with: valueAngle, finalizeStroke: !animate)
        if CGFloat(valueAngle) != currentAngle {
            currentAngle = CGFloat(valueAngle)
            track.strokeColor = scoreType.progressColor?.cgColor
            if animate {
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0
                animation.toValue = 1
                animation.duration = 2
                animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                track.strokeEnd = 1
                track.add(animation, forKey: "growAnimation")
            }
        }
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        knob.strokeColor = UIColor.backgroundSecondary.cgColor
    }
}
