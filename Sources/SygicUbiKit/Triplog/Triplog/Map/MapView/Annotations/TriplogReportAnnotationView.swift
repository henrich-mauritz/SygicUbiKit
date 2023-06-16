import Foundation
import MapKit

public class TriplogReportAnnotationView: MKAnnotationView {
    public static let reuseIndentifier: String = "SYReportAnotationView"

    public var color: UIColor = SevernityLevel.one.toColor() {
        didSet {
            circle.backgroundColor = color
        }
    }

    public var speed: Int = 0 {
        didSet {
            let formatString = "triplog.mapReport.anotationYourSpeed".localized
            label.text = String(format: formatString, speed)
        }
    }

    private let circle = UIView()

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.backgroundColor = .clear
        label.font = .stylingFont(.regular, with: 16)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        return label
    }()

    private let labelBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundPrimary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Styling.cornerRadiusSecondary
        return view
    }()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = nil
        backgroundColor = .clear
        frame = CGRect(x: 0, y: 0, width: 170, height: 85)
        centerOffset = CGPoint(x: 0, y: -20)
        setupView()
        setupConstraints()
        circle.layer.cornerRadius = 20
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        image = nil
    }

    private func setupView() {
        label.translatesAutoresizingMaskIntoConstraints = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelBackgroundView)
        addSubview(label)
        addSubview(circle)
    }

    private func setupConstraints() {
        var constraints = [circle.bottomAnchor.constraint(equalTo: bottomAnchor)]

        constraints.append(circle.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(circle.widthAnchor.constraint(equalToConstant: 40))
        constraints.append(circle.heightAnchor.constraint(equalToConstant: 40))

        constraints.append(label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8))
        constraints.append(label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8))
        constraints.append(label.bottomAnchor.constraint(equalTo: circle.topAnchor, constant: -14))
        constraints.append(label.topAnchor.constraint(equalTo: topAnchor))

        constraints.append(labelBackgroundView.topAnchor.constraint(equalTo: label.topAnchor))
        constraints.append(labelBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(labelBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(labelBackgroundView.bottomAnchor.constraint(equalTo: label.bottomAnchor))

        NSLayoutConstraint.activate(constraints)
    }
}
