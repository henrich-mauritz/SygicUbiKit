import Foundation
import UIKit

public class DrivingTransportTypePopupController: UIViewController {
    public var completionBlock: ((_ selectedTransport: DrivingTransportType?) -> ())?

    public let bubble: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundModal
        view.layer.cornerRadius = Styling.cornerRadiusModalPopup
        view.clipsToBounds = true
        return view
    }()

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.thin, with: 30)
        label.textColor = .foregroundModal
        label.numberOfLines = 0
        label.textAlignment = .center
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        label.text = "driving.typePopup.title".localized
        return label
    }()

    public lazy var backButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.secondary)
        button.titleLabel.text = "driving.typePopup.back".localized
        button.addTarget(self, action: #selector(backButtonPressed(_:)), for: .touchUpInside)
        return button
    }()

    private let backButtonWidth: CGFloat = 230

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let gridSpacing: CGFloat = 10

        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = gridSpacing
        rowStack.addArrangedSubview(transportTypeButton(for: .bus))
        rowStack.addArrangedSubview(transportTypeButton(for: .train))

        let rowStack2 = UIStackView()
        rowStack2.axis = .horizontal
        rowStack2.spacing = gridSpacing
        rowStack2.addArrangedSubview(transportTypeButton(for: .passenger))
        rowStack2.addArrangedSubview(transportTypeButton(for: .other))

        let rootStack = UIStackView()
        rootStack.axis = .vertical
        rootStack.alignment = .center
        rootStack.spacing = gridSpacing
        rootStack.addArrangedSubview(titleLabel)
        rootStack.setCustomSpacing(24, after: titleLabel)
        rootStack.addArrangedSubview(rowStack)
        rootStack.addArrangedSubview(rowStack2)
        rootStack.setCustomSpacing(24, after: rowStack2)
        rootStack.addArrangedSubview(backButton)

        rootStack.translatesAutoresizingMaskIntoConstraints = false
        bubble.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        view.addSubview(bubble)
        bubble.cover(with: rootStack, insets: NSDirectionalEdgeInsets(top: 32, leading: 32, bottom: 32, trailing: 32))

        var constraints = [NSLayoutConstraint]()
        constraints.append(backButton.widthAnchor.constraint(equalToConstant: backButtonWidth))
        constraints.append(bubble.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(bubble.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        PopupManager.shared.popupDidDisappear(self)
        super.viewDidDisappear(animated)
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    @objc
func transportButtonPressed(_ sender: UIControl) {
        completionBlock?(DrivingTransportType(rawValue: sender.tag))
        dismiss(animated: true, completion: nil)
    }

    @objc
func backButtonPressed(_ sender: Any) {
        completionBlock?(nil)
        dismiss(animated: true, completion: nil)
    }

    private func transportTypeButton(for type: DrivingTransportType) -> TransportTileButton {
        let busButton = TransportTileButton()
        busButton.tag = type.rawValue
        busButton.addTarget(self, action: #selector(transportButtonPressed(_:)), for: .touchUpInside)
        switch type {
        case .bus:
            busButton.iconView.image = UIImage(named: "transportTypeBus", in: .module, compatibleWith: nil)
            busButton.titleLabel.text = "driving.typePopup.bus".localized
        case .train:
            busButton.iconView.image = UIImage(named: "transportTypeTrain", in: .module, compatibleWith: nil)
            busButton.titleLabel.text = "driving.typePopup.train".localized
        case .passenger:
            busButton.iconView.image = UIImage(named: "transportTypePassenger", in: .module, compatibleWith: nil)
            busButton.titleLabel.text = "driving.typePopup.passenger".localized
        default:
            busButton.iconView.image = UIImage(named: "transportTypeRocket", in: .module, compatibleWith: nil)
            busButton.titleLabel.text = "driving.typePopup.other".localized
        }
        return busButton
    }
}
