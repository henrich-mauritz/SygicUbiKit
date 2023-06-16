import Foundation
import UIKit

// MARK: - ToastMessage

public class ToastMessage {
    public static let shared: ToastMessage = ToastMessage()
    private var currentPresented: ToastView?
    private init() {}

    //MARK: - Behaviour

    public func present(message toastMessage: ToastPresentable, completion: ((Bool) -> Void)?) {
        if let currentToast = currentPresented {
            currentToast.removeFromSuperview()
            currentPresented = nil
            self.prepareView(with: toastMessage)
            self.animateIn(completion: completion)
        } else {
            self.prepareView(with: toastMessage)
            animateIn(completion: completion)
        }
    }
}

//MARK: - Utils

extension ToastMessage {
    private var topMostViewController: UIViewController? {
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

//MARK: - Layout

extension ToastMessage {
    private func prepareView(with toastMessage: ToastPresentable) {
        currentPresented = ToastView()
        currentPresented?.update(viewModel: toastMessage)
        layoutMessage(view: currentPresented!)
    }

    private func layoutMessage(view: ToastView) {
        guard let topView = topMostViewController?.view else {
            return
        }
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(view)
        view.backgroundColor = .clear

        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 0),
            view.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: 0),
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 150),
            view.centerYAnchor.constraint(equalTo: topView.centerYAnchor)
        ])
        view.setupLayout()
        topView.layoutIfNeeded()
    }
}

//MARK: - Animation

extension ToastMessage {
    private func animateOut() {
        guard let currentView = self.currentPresented, let _ = currentView.superview else {
            return
        }

        currentView.animateOut()
    }

    private func animateIn(completion: ((_ finished: Bool) -> Void)?) {
        guard let currentView = self.currentPresented, let _ = currentView.superview else {
            if let completion = completion {
                completion(false)
            }
            return
        }

        currentView.animateIn(completion: completion)
    }
}
