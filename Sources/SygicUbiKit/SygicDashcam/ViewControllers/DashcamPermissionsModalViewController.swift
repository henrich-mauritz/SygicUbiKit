import UIKit

class DashcamPermissionsModalViewController: StylingPopupViewController {
    public static var shouldShowPermissionsPopup: Bool {
        !DashcamOnboardingPermissionsViewController.hasAllPermissions
    }

    public static var cameraPermission: Bool {
        DashcamOnboardingPermissionsViewController.hasCameraPermission
    }

    public static var libraryPermission: Bool {
        DashcamOnboardingPermissionsViewController.hasPhotosAccess
    }

    private var subtitle: NSAttributedString? {
        if soundPermisson {
            let attributedSubtitle = NSMutableAttributedString(string: "dashcam.permissions.subtitleSound".localized)
            return attributedSubtitle
        } else {
            let cameraPermission = DashcamPermissionsModalViewController.cameraPermission
            let photosPermission = DashcamPermissionsModalViewController.libraryPermission
            var attributedSubtitle: NSMutableAttributedString
            if !cameraPermission && !photosPermission {
                attributedSubtitle = NSMutableAttributedString(string: "dashcam.permissions.subtitleCamAndPhotos".localized)
            } else if !photosPermission {
                attributedSubtitle = NSMutableAttributedString(string: "dashcam.permissions.subtitlePhotos".localized)
            } else {
                attributedSubtitle = NSMutableAttributedString(string: "dashcam.permissions.subtitleCamera".localized)
            }
            let cameraSubstring = "dashcam.permissions.permissionCamera".localized
            let photosSubstring = "dashcam.permissions.permissionPhotos".localized
            if let range = attributedSubtitle.string.range(of: cameraSubstring) {
                attributedSubtitle.addAttributes([NSAttributedString.Key.font: UIFont.stylingFont(.bold, with: subtitleSize)], range: NSRange(range, in: attributedSubtitle.string))
            }
            if let range = attributedSubtitle.string.range(of: photosSubstring) {
                attributedSubtitle.addAttributes([NSAttributedString.Key.font: UIFont.stylingFont(.bold, with: subtitleSize)], range: NSRange(range, in: attributedSubtitle.string))
            }
            return attributedSubtitle
        }
    }

    private let soundPermisson: Bool

    private var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "app"
    }

    public required init(soundPermisson: Bool) {
        self.soundPermisson = soundPermisson
        super.init(nibName: nil, bundle: nil)
        setupTextAndButtons()
    }

    required init?(coder: NSCoder) {
        self.soundPermisson = false
        super.init(coder: coder)
    }

    private func setupTextAndButtons() {
        let format = soundPermisson ? "dashcam.permissions.titleSound".localized : "dashcam.permissions.titleVideo".localized
        titleLabel.text = String(format: format, appName)
        subtitleLabel.attributedText = subtitle
        settingsButton.titleLabel.text = "dashcam.permissions.settingsButton".localized.uppercased()
        settingsButton.addTarget(self, action: #selector(openSettingsButtonPressed), for: .touchUpInside)
        cancelButton.titleLabel.text = "dashcam.permissions.closeButton".localized.uppercased()
        cancelButton.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        imageViewTitleConstraint.constant = -40
    }

    @objc private func dismissButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func openSettingsButtonPressed() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: { [weak self] _ in
            self?.dismissButtonPressed()
        })
    }
}
