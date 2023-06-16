import UIKit

public class TriplogListDateheaderView: UICollectionReusableView {
    private let contentsView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = true
        view.backgroundColor = .backgroundPrimary
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.regular, with: 16)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var reuseIdentifier: String? {
        return TriplogListDateheaderView.headerIdentifier
    }

    private func setupLayout() {
        cover(with: contentsView)
        contentsView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentsView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentsView.centerYAnchor, constant: 0),
        ])
    }

    func update(title: String) {
        titleLabel.text = title
    }
}
