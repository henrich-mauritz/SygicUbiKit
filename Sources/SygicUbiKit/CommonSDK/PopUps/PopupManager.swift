import Foundation
import UIKit

public class PopupManager {
    public static var shared: PopupManager = PopupManager()

    typealias Popup = (vc: UIViewController, presenter: UIViewController, animated: Bool)
    private var popups: [Popup] = []
    private var isPresenting: Bool = false
    private init() {}

    public func presentModalPopup(_ popupViewController: UIViewController, on presenter: UIViewController, animated: Bool = true) {
        popups.append((vc: popupViewController, presenter: presenter, animated: animated))
        
        presentPopup()
    }

    public func popupDidDisappear(_ modal: UIViewController) {
        isPresenting = false
        presentPopup()
    }

    private func presentPopup() {
        guard isPresenting == false else { return }
        guard let nextPopup = popups.first else { return }
        popups.remove(at: 0)
        nextPopup.presenter.present(nextPopup.vc, animated: nextPopup.animated, completion: nil)
        isPresenting = true
    }
}
