import UIKit

class NewsTitleSectionHeaderView: UITableViewHeaderFooterView {

    //MARK: - Properties

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        return label
    }()
    
    private let titleContainer: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .backgroundPrimary
        view.clipsToBounds = true
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //MARK: - LifeCycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.backgroundColor = .backgroundPrimary
        addSubview(titleContainer)
        titleContainer.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleContainer.topAnchor.constraint(equalTo: topAnchor, constant: -32),
            titleContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            titleContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 32)
        ])
    }

    public func configure(with title: String?) {
        titleLabel.text = title
    }
}
