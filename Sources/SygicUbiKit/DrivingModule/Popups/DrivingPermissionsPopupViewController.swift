import CoreLocation
import CoreMotion
import UIKit

public class DrivingPermissionsPopupViewController: StylingPopupViewController {
    public static func shouldShowPermissionsPopup(automaticTripDetection: Bool) -> Bool {
        if !preciseLocation {
            return true
        }
        if automaticTripDetection {
            return !locatioAlwaysPermission || !motionPermission
        } else {
            return !locationPermission || !motionPermission
        }
    }

    public static var locationPermission: Bool {
        locatioAlwaysPermission || CLLocationManager().authorizationStatus == .authorizedWhenInUse
    }

    public static var locatioAlwaysPermission: Bool {
        return CLLocationManager().authorizationStatus == .authorizedAlways
    }

    public static var preciseLocation: Bool {
        if CLLocationManager().accuracyAuthorization == .reducedAccuracy {
            return false
        }
        return true
    }

    public static var motionPermission: Bool {
        CMMotionActivityManager.authorizationStatus() == .authorized
    }

    private var subtitle: NSAttributedString? {
        let locationPermission = DrivingPermissionsPopupViewController.locationPermission
        let motionPermission = DrivingPermissionsPopupViewController.motionPermission
        var attributedSubtitle: NSMutableAttributedString
        if !locationPermission && !motionPermission {
            attributedSubtitle = NSMutableAttributedString(string: "driving.permission.subtitleLocationMotion".localized)
        } else if !motionPermission {
            attributedSubtitle = NSMutableAttributedString(string: "driving.permission.subtitleMotion".localized)
        } else {
            if requireLocationAlwaysPermisson {
                attributedSubtitle = NSMutableAttributedString(string: "driving.permission.subtitleAlwaysLocation".localized)
            } else {
                attributedSubtitle = NSMutableAttributedString(string: "driving.permission.subtitleLocation".localized)
            }
        }
        let locationSubstring = "driving.permission.locationBoldSubstring".localized
        let motionSubstring = "driving.permission.motionBoldSubstring".localized
        if let range = attributedSubtitle.string.range(of: locationSubstring) {
            attributedSubtitle.addAttributes([NSAttributedString.Key.font: UIFont.stylingFont(.bold, with: subtitleSize)], range: NSRange(range, in: attributedSubtitle.string))
        }
        if let range = attributedSubtitle.string.range(of: motionSubstring) {
            attributedSubtitle.addAttributes([NSAttributedString.Key.font: UIFont.stylingFont(.bold, with: subtitleSize)], range: NSRange(range, in: attributedSubtitle.string))
        }
        return attributedSubtitle
    }

    private let requireLocationAlwaysPermisson: Bool

    public required init(requireLocationAlwaysPermisson: Bool) {
        self.requireLocationAlwaysPermisson = requireLocationAlwaysPermisson
        super.init(nibName: nil, bundle: nil)
        setupTextAndButtons()
    }

    required init?(coder: NSCoder) {
        self.requireLocationAlwaysPermisson = false
        super.init(coder: coder)
    }

    private func setupTextAndButtons() {
        let format = "driving.permission.title".localized
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "app"
        titleLabel.text = String(format: format, appName)
        if !DrivingPermissionsPopupViewController.preciseLocation {
            subtitleLabel.text = "driving.permission.subtitlePreciseLocation".localized
            subtitleLabel.textAlignment = .natural
        } else {
            subtitleLabel.attributedText = subtitle
        }
        settingsButton.titleLabel.text = "driving.permission.settingsButton".localized.uppercased()
        settingsButton.addTarget(self, action: #selector(openSettingsButtonPressed), for: .touchUpInside)
        cancelButton.titleLabel.text = "driving.permission.closeButton".localized.uppercased()
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
