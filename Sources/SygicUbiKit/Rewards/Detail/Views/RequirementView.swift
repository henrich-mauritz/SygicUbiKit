import Foundation
import UIKit

class RequirementsView: UIStackView, InjectableType {
    let margin: CGFloat = 16

    required init(with requirements: [RewardRequirement]) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = margin
        for r in requirements {
            addRequirement(r.text, fullfilled: r.isFulfilled)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addRequirement(_ description: String, fullfilled: Bool) {
        let itemView: RewardRequirementItemView = RewardRequirementItemView(frame: .zero)
        itemView.addRequirement(description, fullfilled: fullfilled)
        addArrangedSubview(itemView)
    }
}
