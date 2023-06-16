import UIKit

class RewardsLoalityCardView: RewardDiscountCodeView {
    override func setupLayout() {
        super.setupLayout()
        innerStackView.removeArrangedSubview(yourCodeLabel)
        yourCodeLabel.removeFromSuperview()
        codeLabel.adjustsFontSizeToFitWidth = false
        codeLabel.numberOfLines = 0
        codeLabel.font = UIFont.stylingFont(.regular, with: 16)
    }
}
