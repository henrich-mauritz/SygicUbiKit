import UIKit

// MARK: - DiscountCodesInfoTableViewCell

class DiscountCodesInfoTableViewCell: UITableViewCell {
    public static let cellReuseIdentifier: String = "DiscountCodesInfoTableViewCell"

    public let title: UILabel = {
        let label = UILabel()
        label.font = .stylingFont(.bold, with: 16)
        label.textColor = .foregroundPrimary
        label.text = " " + "discounts.yourCodes.howToTitle".localized
        return label
    }()

    ///TODO neskorej prerobit kde stringy budu chodit zo server, zatial ale takto hardcoded
    ///https://jira.sygic.com/browse/TRIG-689

    ///special subtitle is only for Triglav discount codes for motorbikes
    ///https://jira.sygic.com/browse/TRIG-2783
    private lazy var subtitle: UITextView = getSubtitleView(specialSubtitle: false)

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .top
        view.spacing = 10
        view.distribution = .fill
        return view
    }()

    private let fillerView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return view
    }()
    
    func setSpecialMotorbikeSubtitle() {
        subtitle.attributedText = getAttributedSubtitle(specialSubtitle: true)
    }

    private func getAttributedSubtitle(specialSubtitle: Bool = false) -> NSAttributedString {
        let companyName = Bundle.companyName
        let fullText = String(format: specialSubtitle ? "discounts.yourCodes.howToDescriptionMoto".localized : "discounts.yourCodes.howToDescription".localized, companyName ?? "", Bundle.displayName ?? "")
        let linkText = "discounts.yourCodes.howToDescriptionLink".localized
        let text = NSMutableAttributedString(string: fullText,
                                             attributes: [
                                                 NSAttributedString.Key.foregroundColor: UIColor.foregroundPrimary,
                                                 NSAttributedString.Key.font: UIFont.itemTitleFont(),
                                             ])
        if let range = fullText.range(of: linkText) {
            let linkAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.link: URL(string: "http://drajv.triglav.si/pogoji-uporabe")!,
                NSAttributedString.Key.font: UIFont.itemTitleFont(),
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.foregroundColor: UIColor.foregroundPrimary,
            ]
            text.addAttributes(linkAttributes, range: NSRange(range, in: fullText))
        }
        let linkDrajv = "drajv.triglav.si"
        if let range = fullText.range(of: linkDrajv) {
            let linkAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.link: URL(string: "http://drajv.triglav.si")!,
                NSAttributedString.Key.font: UIFont.itemTitleFont(),
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.foregroundColor: UIColor.foregroundPrimary,
            ]
            text.addAttributes(linkAttributes, range: NSRange(range, in: fullText))
        }
        
        return text
    }
    
    private func getSubtitleView(specialSubtitle: Bool) -> UITextView {
        let view = UITextView()
        view.backgroundColor = .backgroundPrimary
        view.font = .itemTitleFont()
        view.textColor = .foregroundPrimary
        view.tintColor = .foregroundPrimary
        view.dataDetectorTypes = .link
        view.attributedText = getAttributedSubtitle(specialSubtitle: specialSubtitle)
        view.delegate = self
        view.isEditable = false
        view.isScrollEnabled = false
        return view
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(subtitle)
        stackView.addArrangedSubview(fillerView)
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        subtitle.becomeFirstResponder()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupConstraints() {
        var constraints = [stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin)]
        constraints.append(stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: UITextViewDelegate

extension DiscountCodesInfoTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }

    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }
}
