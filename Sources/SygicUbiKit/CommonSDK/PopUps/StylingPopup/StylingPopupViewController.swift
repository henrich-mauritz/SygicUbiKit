import Foundation
import UIKit

open class StylingPopupViewController: UIViewController {
    private var cancelcallBack: (() -> ())?
    private var actioncallBack: (() -> ())?

    var viewModel: StylingPopUpViewModelDataType?

    public let bubble: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundModal
        view.layer.cornerRadius = Styling.cornerRadiusModalPopup
        view.clipsToBounds = true
        return view
    }()

    public let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "permissionsPopup", in: .module, compatibleWith: nil))
        imageView.clipsToBounds = false
        imageView.layer.masksToBounds = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.thin, with: 30)
        label.textColor = .foregroundModal
        label.numberOfLines = 0
        label.textAlignment = .center
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: subtitleSize)
        label.textColor = .foregroundModal
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    public let subtitleSize: CGFloat = 14

    public let settingsButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.normalModal)
        return button
    }()

    public let cancelButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.secondaryModal)
        return button
    }()

    public lazy var imageViewTitleConstraint: NSLayoutConstraint = {
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16)
    }()

    var imageHeightConstraint: NSLayoutConstraint?

    let buttonsStack = UIStackView()

    var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var bottomStackConstraint: NSLayoutConstraint?

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open func configure(with viewModel: StylingPopUpViewModelDataType?) {
        self.viewModel = viewModel
        imageView.image = viewModel?.image
        titleLabel.text = viewModel?.title
        if let attSubtitle = viewModel?.attributedSubtitle {
            subtitleLabel.attributedText = attSubtitle
        } else {
            subtitleLabel.text = viewModel?.subtitle
        }
        cancelButton.titleLabel.text = viewModel?.cancelButtonTitle
        settingsButton.titleLabel.text = viewModel?.actionButtonTitle
        if let cancelAction = viewModel?.cancelButonAction {
            cancelButton.removeTarget(nil, action: nil, for: .allEvents)
            cancelcallBack = cancelAction
            cancelButton.addTarget(self, action: #selector(StylingPopupViewController.cancelPressed), for: .touchUpInside)
        }
        if let settingsAction = viewModel?.actionButtonAction {
            settingsButton.removeTarget(nil, action: nil, for: .allEvents)
            actioncallBack = settingsAction
            settingsButton.addTarget(self, action: #selector(StylingPopupViewController.settingsPressed), for: .touchUpInside)
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupLayout(on: view)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        PopupManager.shared.popupDidDisappear(self)
    }

    open func setupLayout(on baseView: UIView) {
        baseView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(900), for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        

        buttonsStack.axis = .vertical
        buttonsStack.spacing = 16
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        if let viewModel = viewModel {
            if viewModel.actionButtonTitle != nil {
                buttonsStack.addArrangedSubview(settingsButton)
            }
            if viewModel.cancelButtonTitle != nil {
                buttonsStack.addArrangedSubview(cancelButton)
            }
        } else {
            buttonsStack.addArrangedSubview(settingsButton)
            buttonsStack.addArrangedSubview(cancelButton)
        }

        baseView.addSubview(bubble)
        bubble.addSubview(imageView)
        bubble.addSubview(titleLabel)
        bubble.addSubview(subtitleLabel)
        bubble.addSubview(buttonsStack)

        //Portrait Constraints
        var constraints = [NSLayoutConstraint]()
        constraints.append(bubble.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 30))
        constraints.append(bubble.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -30))
        constraints.append(bubble.centerYAnchor.constraint(equalTo: baseView.centerYAnchor))
        constraints.append(bubble.topAnchor.constraint(greaterThanOrEqualTo: baseView.topAnchor, constant: 56))
        constraints.append(bubble.bottomAnchor.constraint(lessThanOrEqualTo: baseView.bottomAnchor, constant: -56))
        
        constraints.append(imageView.topAnchor.constraint(equalTo: bubble.topAnchor, constant: imageView.image == nil ? 0 : 32))
        constraints.append(imageView.leadingAnchor.constraint(greaterThanOrEqualTo: bubble.leadingAnchor, constant: 20))
        constraints.append(imageView.trailingAnchor.constraint(greaterThanOrEqualTo: bubble.trailingAnchor, constant: -20))
        constraints.append(imageView.centerXAnchor.constraint(equalTo: bubble.centerXAnchor))
        imageHeightConstraint = imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: imageView.image == nil ? 0 : 100)
        constraints.append(imageHeightConstraint!)
        constraints.append(imageViewTitleConstraint)
        
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 32))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -32))
        constraints.append(titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -20))
        
        constraints.append(subtitleLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 43))
        constraints.append(subtitleLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -43))
        constraints.append(subtitleLabel.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -20))
        constraints.append(subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bubble.bottomAnchor, constant: -32))
        
        constraints.append(buttonsStack.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 43))
        constraints.append(buttonsStack.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -43))
        constraints.append(buttonsStack.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -30))
        
        portraitConstraints = constraints
        NSLayoutConstraint.activate(portraitConstraints)
        if buttonsStack.arrangedSubviews.count == 0 {
            buttonsStack.removeFromSuperview()
        }
        
        //LandscapeConstratins
        baseView.setNeedsLayout()
        var landscapeConstraints = [NSLayoutConstraint]()
        landscapeConstraints.append(bubble.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 52))
        landscapeConstraints.append(bubble.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 95))
        landscapeConstraints.append(bubble.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -95))
        landscapeConstraints.append(bubble.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -52))
        
        landscapeConstraints.append(imageView.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 8))
        landscapeConstraints.append(imageView.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 16))
        landscapeConstraints.append(imageView.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -8))
        
        landscapeConstraints.append(buttonsStack.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -40))
        landscapeConstraints.append(buttonsStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16))
        landscapeConstraints.append(buttonsStack.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -40))
        
        landscapeConstraints.append(subtitleLabel.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -20))
        landscapeConstraints.append(subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16))
        landscapeConstraints.append(subtitleLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -40))
        
        landscapeConstraints.append(titleLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 33))
        landscapeConstraints.append(titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16))
        landscapeConstraints.append(titleLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -40))
        landscapeConstraints.append(titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -16))
        
        self.landscapeConstraints = landscapeConstraints
    }

    private func activateLayout() {
        if UIWindow.isLandscape {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        } else {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        activateLayout()
    }

    @objc
private func cancelPressed() {
        guard let action = cancelcallBack else {
            return
        }
        action()
    }

    @objc
private func settingsPressed() {
        guard let action = actioncallBack else {
            return
        }
        action()
    }
}
