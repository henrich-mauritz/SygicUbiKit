import Foundation
import UIKit

class HighlightedEventView: UIView {
    private let eventView: EventStatView = EventStatView()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.numberOfLines = 0
        return label
    }()

    let clickableText: UITextView = {
        let view = UITextView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.font = .stylingFont(.regular, with: 14)
        view.textColor = .foregroundPrimary
        view.tintColor = .actionPrimary
        view.adjustsFontForContentSizeCategory = true
        view.isEditable = false
        view.isScrollEnabled = false
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        return view
    }()

    private let margin: CGFloat = 16

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with event: EventStatViewModel) {
        eventView.update(with: event)

        if let description = event.description {
            let substrings = description.split { separator -> Bool in
                ".!".contains(separator)
            }
            guard let highlightedSubstring = substrings.first, let range = description.range(of: highlightedSubstring) else {
                descriptionLabel.text = description
                return
            }
            let string = NSMutableAttributedString(attributedString: NSAttributedString(string: description))
            string.addAttributes([.font: UIFont.stylingFont(.bold, with: 16)], range: NSRange(range, in: description))
            descriptionLabel.attributedText = string
        } else {
            descriptionLabel.text = nil
        }
        clickableText.attributedText = event.clickableText
    }

    private func setupLayout() {
        backgroundColor = .backgroundTertiary
        layer.cornerRadius = Styling.cornerRadiusModalPopup
        eventView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(eventView)
        addSubview(descriptionLabel)
        addSubview(clickableText)
        var constrains: [NSLayoutConstraint] = []
        constrains.append(eventView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin))
        constrains.append(eventView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin))
        constrains.append(eventView.topAnchor.constraint(equalTo: topAnchor, constant: margin / 2.0))
        constrains.append(descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin))
        constrains.append(descriptionLabel.trailingAnchor.constraint(equalTo: eventView.scoreLabel.leadingAnchor))
        constrains.append(descriptionLabel.topAnchor.constraint(equalTo: eventView.bottomAnchor, constant: 0))
        constrains.append(descriptionLabel.bottomAnchor.constraint(equalTo: clickableText.topAnchor, constant: -margin))
        constrains.append(clickableText.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor))
        constrains.append(clickableText.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor))
        constrains.append(clickableText.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin * 1.5))
        NSLayoutConstraint.activate(constrains)
    }
}
