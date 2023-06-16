import Foundation
import UIKit

class DashcamVisionControlsView: DashcamControlsView {
    var visionOverlayView: VisionOverlayView? {
        willSet {
            if visionOverlayView != nil {
                visionOverlayView?.removeFromSuperview()
            }
        }
        didSet {
            guard let overlay = visionOverlayView else { return }
            insertSubview(overlay, aboveSubview: bottomBackgroundGradient)
            overlay.translatesAutoresizingMaskIntoConstraints = false
            var constraints = [NSLayoutConstraint]()
            constraints.append(overlay.topAnchor.constraint(equalTo: topAnchor))
            constraints.append(overlay.bottomAnchor.constraint(equalTo: bottomAnchor))
            constraints.append(overlay.leadingAnchor.constraint(equalTo: leadingAnchor))
            constraints.append(overlay.trailingAnchor.constraint(equalTo: trailingAnchor))
            NSLayoutConstraint.activate(constraints)
        }
    }

    @objc override func settingsPressed(_ sender: UIButton) {
        delegate?.dashcamControlSettingsPressed(self, settingsDataSource: DashcamVisionSettingsDataSouce(), sender: sender)
    }

}
