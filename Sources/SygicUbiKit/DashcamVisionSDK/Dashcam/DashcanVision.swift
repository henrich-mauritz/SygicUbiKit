import Foundation

// MARK: - DashcamVision

class DashcamVision: Dashcam {
    static func dashcamControllerWithVision(dataProvider: DashcamVisionProviderProtocol,
                                                   drivingTheme: Bool = false) -> Dashcam {
        let session = DashcamVisionSession(provider: dataProvider)
        let dashcam = DashcamVision(session: session, isDarkTheme: drivingTheme)
        return dashcam
    }

    override func resolvedOnboarding() -> DashcamOnboardingSortable {
        guard let resolved = container.resolve(DashcamOnboardingSortable.self) else {
            fatalError()
        }
        return resolved
    }
    
    override func createDashcamController() -> DashcamViewController {
        return DashcamVisionViewController(session: self.session)
    }
    
}

// MARK: - DashcamVisionViewController
class DashcamVisionViewController: DashcamViewController {
    override func createControlView() -> DashcamControlsViewProtocol {
        guard let customControls = container.resolve(DashcamControlsViewProtocol.self, argument: session.provider) else {
                fatalError("The controls weren't injected in the vision module")
        }
        return customControls
    }
    
    /* same as Dashcam
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        //return .allButUpsideDown
    }
     */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VisionManager.shared.delegate?.beginEducation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VisionManager.shared.delegate?.stopEducation()
    }
    
    override func didSelectSettings() {
        super.didSelectSettings()
        VisionManager.shared.delegate?.setEducation(hidden: true)
    }
    
    override func didDismissSettings() {
        super.didDismissSettings()
        VisionManager.shared.delegate?.setEducation(hidden: false)
    }
    
}
