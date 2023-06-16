import Foundation
import UIKit

public class SosAssistancePermissionPopupViewController: StylingPopupViewController {
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupTextAndButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTextAndButtons() {
        let format = "assistance.permissionPopup.title".localized
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "app"
        titleLabel.text = String(format: format, appName)
        subtitleLabel.text = "assistance.permissionPopup.subtitle".localized
        settingsButton.titleLabel.text = "assistance.permissionPopup.primaryButton".localized.uppercased()
        settingsButton.addTarget(self, action: #selector(openSettingsButtonPressed), for: .touchUpInside)
        cancelButton.titleLabel.text = "assistance.permissionPopup.secondaryButton".localized.uppercased()
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
