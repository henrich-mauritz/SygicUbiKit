import AVFoundation
import Photos
import UIKit

// MARK: - DashcamOnboardingDelegate

public protocol DashcamOnboardingDelegate: AnyObject {
    func automaticTripDetectionEnabled() -> Bool
    func dashcamOnboardingCompleted()
    func dashcamOpensAppSettings()
}

// MARK: - DashcamOnboardingViewController

open class DashcamOnboardingViewController: UIViewController, DashcamOnboardable, InjectableType {
    public weak var delegate: DashcamOnboardingDelegate?

    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return imageView
    }()

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DashcamColorManager.shared.isDark ? .white : .foregroundOnboarding
        label.font = UIFont.stylingFont(.thin, with: 30)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        label.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        return label
    }()

    public lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DashcamColorManager.shared.isDark ? .white : .foregroundOnboarding
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = margin
        return stack
    }()

    public lazy var nextButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.normal)
        button.titleLabel.text = "dashcam.onboarding.buttonNext".localized.uppercased()
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        return button
    }()

    public lazy var closeButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.plain)
        button.titleLabel.text = "dashcam.onboarding.buttonClose".localized
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        return button
    }()

    open var type: DashcamOnboardingOrderType {
        return .informative
    }

    private var portraitConstraints: [NSLayoutConstraint] = []

    private lazy var landscapeConstraints: [NSLayoutConstraint] = {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(imageView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor))
        constraints.append(imageView.leadingAnchor.constraint(equalTo: view.safeAreaLeadingAnchor))
        constraints.append(imageView.bottomAnchor.constraint(equalTo: view.safeAreaBottomAnchor))
        constraints.append(imageView.widthAnchor.constraint(equalToConstant: 300))
        constraints.append(titleLabel.centerYAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor, constant: -50))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaTrailingAnchor, constant: -16))
        constraints.append(subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor))
        constraints.append(subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor))
        constraints.append(subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32))
        constraints.append(buttonsStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 64))
        constraints.append(buttonsStack.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -64))
        constraints.append(buttonsStack.topAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor, constant: 16))
        constraints.append(buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaBottomAnchor, constant: -16))
        return constraints
    }()

    let margin: CGFloat = 16
    let biggerMargin: CGFloat = 26
    static let sideMargin: CGFloat = 40
    var sideMargin: CGFloat { DashcamOnboardingViewController.sideMargin }
    let titleMargin: CGFloat = 46

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        guard let orderSteps = container.resolve(DashcamOnboardingSortable.self) else {
            fatalError("The default sortable weren't injected yet")
        }
        let image = orderSteps.defaultBackgroundImageFor(type: type)
        imageView.image = image
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = DashcamColorManager.shared.backgroundColor
        setupLayout()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.dashcamOnboardingShwon, parameters: nil)
    }

    func setupLayout() {
        buttonsStack.addArrangedSubview(nextButton)
        buttonsStack.addArrangedSubview(closeButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(buttonsStack)
        var constraints = [NSLayoutConstraint]()
        constraints.append(imageView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor, constant: 0))
        constraints.append(imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 0))
        constraints.append(imageView.leadingAnchor.constraint(equalTo: view.safeAreaLeadingAnchor, constant: 0))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: view.safeAreaTrailingAnchor, constant: 0))
        constraints.append(imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150))
        constraints.append(titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -margin))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLeadingAnchor, constant: 2 * margin))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaTrailingAnchor, constant: -2 * margin))
        constraints.append(subtitleLabel.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -biggerMargin))
        constraints.append(subtitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLeadingAnchor, constant: sideMargin))
        constraints.append(subtitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaTrailingAnchor, constant: -sideMargin))
        constraints.append(buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaBottomAnchor, constant: -2 * margin))
        constraints.append(buttonsStack.leadingAnchor.constraint(equalTo: view.safeAreaLeadingAnchor, constant: sideMargin))
        constraints.append(buttonsStack.trailingAnchor.constraint(equalTo: view.safeAreaTrailingAnchor, constant: -sideMargin))
        portraitConstraints = constraints
        activateLayout()
    }

    public func dismissOnboarding() {
        delegate?.dashcamOnboardingCompleted()
    }

    public func presentViewController(_ viewController: UIViewController) {
        if let navigationController = navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true, completion: nil)
        }
    }

    @objc open func nextButtonPressed() {
        guard let orderSteps = container.resolve(DashcamOnboardingSortable.self) else {
            fatalError("The default sortable weren't injected yet")
        }

        if let nextType = orderSteps.nextType(from: type) {
            let nextController = orderSteps.controllerFor(step: nextType)
            nextController.delegate = delegate
            navigationController?.pushViewController(nextController, animated: true)
        } else {
            delegate?.dashcamOnboardingCompleted()
        }
    }

    @objc public func closeButtonPressed() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass ||
            self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            activateLayout()
        }
    }

    private func activateLayout() {
        if UIWindow.isPortrait {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            //Gustavo nemal dobry den alebo sa moze stat ze ked nie sme v portrait tak budeme v inom stave ako landscape?
        } else /*if UIApplication.shared.statusBarOrientation.isLandscape*/ {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
}

// MARK: - DashcamOnboardingBlackboxViewController

class DashcamOnboardingBlackboxViewController: DashcamOnboardingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "dashcam.onboarding.blackboxTitle".localized
        subtitleLabel.text = "dashcam.onboarding.blackboxSubtitle".localized
    }

}

// MARK: - DashcamOnboardingPermissionsViewController

class DashcamOnboardingPermissionsViewController: DashcamOnboardingViewController {
    override var type: DashcamOnboardingOrderType {
        return .permissions
    }

    static var hasAllPermissions: Bool {
        hasCameraPermission && hasPhotosAccess
    }

    static var hasCameraPermission: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    static var hasPhotosAccess: Bool {
        PHPhotoLibrary.authorizationStatus() == .authorized
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "dashcam.onboarding.setupTitle".localized
        subtitleLabel.text = "dashcam.onboarding.setupSubtitle".localized
    }

    override func nextButtonPressed() {
        if Self.hasAllPermissions {
            super.nextButtonPressed()
        } else {
            requestPermissions()
        }
    }

    private func requestPermissions() {
        guard let orderSteps = container.resolve(DashcamOnboardingSortable.self) else {
            fatalError("The default sortable weren't injected yet")
        }

        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            imageView.image = orderSteps.backgroundImageFor(permissionType: .cameraPermission)
            askPermissionToVideo()
        } else if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            imageView.image = orderSteps.backgroundImageFor(permissionType: .libraryPermission)
            askPermissionToPhotos()
        } else {
            super.nextButtonPressed()
        }
    }

    func askPermissionToVideo() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
            guard let self = self else { return }
            self.askPermissionToPhotos()
        }
    }

    func askPermissionToPhotos() {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.nextButtonPressed()
                }
            }
        } else {
            super.nextButtonPressed()
        }
    }
    
}

// MARK: - DashcamOnboardingTripDetectionViewController

class DashcamOnboardingTripDetectionViewController: DashcamOnboardingViewController {
    override var type: DashcamOnboardingOrderType {
        return .tripDetection
    }

    var automaticTripDetectionEnabled: Bool {
        if let detectionEnabled = delegate?.automaticTripDetectionEnabled() {
            return detectionEnabled
        }
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if !automaticTripDetectionEnabled {
            closeButton.titleLabel.text = "dashcam.onboarding.tripDetectionButton".localized
        }
        titleLabel.text = "dashcam.onboarding.tripDetectionTitle".localized
        subtitleLabel.text = "dashcam.onboarding.tripDetectionSubtitle".localized
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserDefaults.setDashcamOnboardingSeen()
    }

    override func closeButtonPressed() {
        if automaticTripDetectionEnabled {
            super.closeButtonPressed()
        } else {
            delegate?.dashcamOpensAppSettings()
        }
    }
    
}
