import Foundation
import UIKit

// MARK: - DashcamVisionOnboarding

public class DashcamVisionOnboarding: DashcamOnboardingDefaults {
    private let infoVisioinController = DashcamVisionInfoOnboarding()
    
    override public var orderedSteps: [DashcamOnboardingOrderType] {
        var currentSteps = super.orderedSteps
        currentSteps.insert(.custom(controller: infoVisioinController), at: 1)
        return currentSteps
    }
    
}

// MARK: - DashcamVisionInfoOnboarding

public class DashcamVisionInfoOnboarding: DashcamOnboardingViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(named: "tailgatingOnboarding", in: .module, compatibleWith: nil)
        titleLabel.text = "vision.tailgatingOnboarding.title".localized
        subtitleLabel.text = "vision.tailgatingOnboarding.subtitle".localized
    }

    override public var type: DashcamOnboardingOrderType {
        return .custom(controller: self)
    }

    override public func nextButtonPressed() {
        guard let orderSteps = container.resolve(DashcamOnboardingSortable.self) else {
            fatalError()
        }

        if let nextType = orderSteps.nextType(from: type) {
            let nextController = orderSteps.controllerFor(step: nextType)
            nextController.delegate = delegate
            navigationController?.pushViewController(nextController, animated: true)
        } else {
            delegate?.dashcamOnboardingCompleted()
        }
    }
    
}
