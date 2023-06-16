import Foundation
import UIKit

class MonthlyStatsSectionHeaderView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        cover(with: titleLabel, insets: NSDirectionalEdgeInsets(top: 16, leading: 35, bottom: 10, trailing: 35))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
