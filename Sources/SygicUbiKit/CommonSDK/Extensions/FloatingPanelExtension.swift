import Foundation
import UIKit
import FloatingPanel

extension FloatingPanelController {
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let parentController = self.presentingViewController else {
            return [.portrait, .landscape]
        }
        return parentController.supportedInterfaceOrientations
    }

    override public var shouldAutorotate: Bool { true }
}
