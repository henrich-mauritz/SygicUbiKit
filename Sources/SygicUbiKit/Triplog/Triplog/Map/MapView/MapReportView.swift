import Foundation
import UIKit

// MARK: - MapReportViewDelegate

public protocol MapReportViewDelegate: AnyObject {
    func shouldShowReport()
}

// MARK: - MapReportView

public class MapReportView: UIView {
    public weak var delegate: MapReportViewDelegate?

    public var showButton: Bool = false {
        didSet {
            if showButton {
                addButton()
                UIView.animate(withDuration: 0.2, animations: {
                    self.layoutIfNeeded()
                })
            }
        }
    }

    lazy private var button: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel.text = "triplog.mapReport.button".localized.uppercased()
        button.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
        return button
    }()

    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "triplog.mapReport.title".localized
        label.font = .stylingFont(.bold, with: 16)
        label.textColor = .foregroundPrimary
        return label
    }()

    private let subtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .foregroundPrimary
        label.font = .stylingFont(.regular, with: 16)
        label.text = "triplog.mapReport.subtitle".localized
        label.numberOfLines = 0
        return label
    }()

    private var bottomConstraint: NSLayoutConstraint?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func addButton() {
        addSubview(button)
        bottomConstraint?.isActive = false
        var constraints = [button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)]

        constraints.append(button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))
        constraints.append(button.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 12))
        bottomConstraint = button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        constraints.append(bottomConstraint!)

        NSLayoutConstraint.activate(constraints)
    }

    private func setupConstraints() {
        addSubview(title)
        addSubview(subtitle)
        var constraints = [title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)]

        constraints.append(title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))
        constraints.append(title.topAnchor.constraint(equalTo: topAnchor, constant: 20))

        constraints.append(subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor))
        constraints.append(subtitle.trailingAnchor.constraint(equalTo: title.trailingAnchor))
        constraints.append(subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12))
        bottomConstraint = subtitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        constraints.append(bottomConstraint!)

        NSLayoutConstraint.activate(constraints)
    }

    @objc
private func reportTapped() {
        delegate?.shouldShowReport()
    }
}
