import Foundation
import UIKit

public extension UIApplication {
    static var appStoreUrl: URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "AppStoreUrl") as? String,
              let url = URL(string: urlString) else { return nil }
        return url
    }

    var windowInterfaceOrientation: UIInterfaceOrientation? {
        return windows.first?.windowScene?.interfaceOrientation
    }

    var topMostViewController: UIViewController? {
        if var viewConroller: UIViewController = UIApplication.shared.windows.first?.rootViewController {
            //if there is a modal
            if let modalController = modalViewController(in: viewConroller) {
                viewConroller = modalController
            }

            return viewConroller
        }
        return nil
    }

    private func modalViewController(in controller: UIViewController) -> UIViewController? {
        if let controller = controller.presentedViewController {
            return controller
        }
        return nil
    }
}
