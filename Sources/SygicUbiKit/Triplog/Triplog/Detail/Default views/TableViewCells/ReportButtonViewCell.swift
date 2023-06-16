import UIKit

class ReportButtonView: UIView {
    public let button: StylingButton = {
        let button = StylingButton.button(with: .secondary)
        button.titleLabel.text = "triplog.tripDetailScore.reportSpeedLimitButton".localized.uppercased()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setuplayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setuplayout() {
        backgroundColor = .clear
        addSubview(button)
        var constraints = [NSLayoutConstraint]()
        constraints.append(button.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(button.widthAnchor.constraint(equalToConstant: 300))
        constraints.append(button.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(button.topAnchor.constraint(equalTo: topAnchor, constant: 8))
        NSLayoutConstraint.activate(constraints)
    }
}
