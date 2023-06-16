import UIKit

class AboutYourScoreHeaderView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        cover(with: titleLabel, insets: NSDirectionalEdgeInsets(top: 30, leading: 16, bottom: 20, trailing: 16))
    }

    func update(title: String) {
        titleLabel.text = title
    }
}
