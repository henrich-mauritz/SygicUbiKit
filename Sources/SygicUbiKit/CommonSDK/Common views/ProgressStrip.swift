import Foundation
import UIKit

public class ProgressStrip: UIView {
    public var progress: CGFloat = 0 {
        didSet {
            progressWidthConstraint?.isActive = false
            let progressConstraint = progressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: progress)
            progressConstraint.isActive = true
            progressWidthConstraint = progressConstraint
        }
    }

    public let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .positivePrimary
        return view
    }()

    public let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.semibold, with: 16)
        label.textColor = .foregroundSecondary
        return label
    }()

    public func set(progressColor: UIColor?) {
        progressView.backgroundColor = progressColor
    }

    public let progressHeight: CGFloat = 22

    private var progressWidthConstraint: NSLayoutConstraint?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundSecondary
        layer.cornerRadius = progressHeight / 2
        layer.masksToBounds = true

        progressView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        addSubview(textLabel)

        var constraints = [NSLayoutConstraint]()
        constraints.append(heightAnchor.constraint(equalToConstant: progressHeight))

        constraints.append(progressView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(progressView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(progressView.bottomAnchor.constraint(equalTo: bottomAnchor))
        let progressConstraint = progressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0)
        progressWidthConstraint = progressConstraint
        constraints.append(progressConstraint)

        constraints.append(textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8))
        constraints.append(textLabel.centerYAnchor.constraint(equalTo: centerYAnchor))

        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
