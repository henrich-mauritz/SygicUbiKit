import UIKit

class NewsDetailTableViewCell: UITableViewCell {
    //MARK: - Properties

    private let descrTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundPrimary
        view.font = .stylingFont(.regular, with: 14)
        view.textColor = .foregroundPrimary
        view.tintColor = .actionPrimary
        view.adjustsFontForContentSizeCategory = true
        view.isEditable = false
        view.isScrollEnabled = false
        view.dataDetectorTypes = .link
        view.isSelectable = true
        return view
    }()

    //MARK: - LifeCycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .backgroundPrimary
        backgroundColor = .backgroundPrimary
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.cover(with: descrTextView, insets: NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
    }

    func updateDescription(with text: String?) {
        descrTextView.text = text
    }

    func updateDescription(with attributedString: NSAttributedString) {
        descrTextView.attributedText = attributedString
    }
}
