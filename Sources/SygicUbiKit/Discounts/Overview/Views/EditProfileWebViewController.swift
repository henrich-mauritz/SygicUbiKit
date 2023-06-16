import Foundation
import UIKit

public protocol EditProfileWebViewControllerDelegate: AnyObject {
    func editSuccessFul()
}

// MARK: - EditProfileWebViewController

public class EditProfileWebViewController: AuthPolicyWebViewController {
    weak var delegate: EditProfileWebViewControllerDelegate?

    required init(auth: B2cClientAuth.Policy = .profileEdit) {
        super.init(auth: auth)
        view.backgroundColor = .backgroundPrimary
        activityIndicator.color = .foregroundPrimary
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        let closeButton = UIBarButtonItem(title: "discounts.cancelPresentedView".localized, style: .plain, target: self, action: #selector(closeButtonClicked))
        navigationItem.leftBarButtonItem = closeButton
    }

    override public func authorizationSuccessfull() {
        delegate?.editSuccessFul()
    }

    @objc
func closeButtonClicked() {
        dismiss(animated: true, completion: nil)
    }
}
