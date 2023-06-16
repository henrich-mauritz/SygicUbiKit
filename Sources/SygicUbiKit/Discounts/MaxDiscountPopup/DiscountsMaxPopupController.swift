import UIKit

public extension StylingPopUpViewModel {
    static var discountsMaxPopupViewModel: StylingPopUpViewModel {
        let viewModel = StylingPopUpViewModel(title: "discounts.maxDiscountPopup.title".localized, subtitle: "discounts.maxDiscountPopup.subtitle".localized, actionTitle: "discounts.maxDiscountPopup.button".localized, cancelTitle: nil)
        viewModel.image = UIImage(named: "maxDiscountReached", in: .module, compatibleWith: nil)
        return viewModel
    }
}

// MARK: - DiscountsMaxPopupController

public class DiscountsMaxPopupController: StylingPopupViewController {
    public static var seen: Bool = false

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Self.seen = true
    }
}
