import Foundation
import UIKit

// MARK: - EventStatViewModel

public struct EventStatViewModel: Equatable {
    var type: EventType
    var score: String
    var state: ReportScoreMonthComparision
    var clickableText: NSAttributedString? {
        guard let attString = state.clickableText(for: type) else { return nil }
        return attString
    }

    public static func == (lhs: EventStatViewModel, rhs: EventStatViewModel) -> Bool {
        return lhs.score == rhs.score && lhs.type == rhs.type && lhs.state == rhs.state
    }
}

extension EventStatViewModel {
    var description: String? {
        state.description(for: type)
    }
}

// MARK: - MonthlyStatsEventScoreCellViewModelType

public protocol MonthlyStatsEventScoreCellViewModelType {
    var events: [EventStatViewModel] { get }
    var highlightedEvent: EventStatViewModel? { get }
}

// MARK: - MonthlyStatsEventScoreCellDelegate

public protocol MonthlyStatsEventScoreCellDelegate: AnyObject {
    func shouldOpenSafariController(with url: URL)
}

// MARK: - MonthlyStatsEventScoreCell

class MonthlyStatsEventScoreCell: BubbleTableViewCell {
    let eventsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()

    let highlightedEventView = HighlightedEventView()

    var eventStackViewTopConstraint: NSLayoutConstraint!
    weak var delegate: MonthlyStatsEventScoreCellDelegate?
    var eventStackViewToHighlightedEventConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        eventsStackView.removeAll()
        super.prepareForReuse()
    }

    func update(with viewModel: MonthlyStatsEventScoreCellViewModelType) {
        if let highlightedEvent = viewModel.highlightedEvent {
            highlightedEventView.update(with: highlightedEvent)
            highlightedEventView.isHidden = false
            eventStackViewTopConstraint.isActive = false
            eventStackViewToHighlightedEventConstraint.isActive = true
        } else {
            highlightedEventView.isHidden = true
            eventStackViewToHighlightedEventConstraint.isActive = false
            eventStackViewTopConstraint.isActive = true
        }
        for event in viewModel.events {
            let eventView = EventStatView()
            eventView.update(with: event)
            eventsStackView.addArrangedSubview(eventView)
        }
    }

    private func setupLayout() {
        highlightedEventView.translatesAutoresizingMaskIntoConstraints = false
        eventsStackView.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainerView.addSubview(highlightedEventView)
        bubbleContainerView.addSubview(eventsStackView)
        eventStackViewToHighlightedEventConstraint = eventsStackView.topAnchor.constraint(equalTo: highlightedEventView.bottomAnchor, constant: margin / 2.0)
        eventStackViewTopConstraint = eventsStackView.topAnchor.constraint(equalTo: bubbleContainerView.topAnchor, constant: margin / 2.0)
        var constrains: [NSLayoutConstraint] = []
        constrains.append(highlightedEventView.leadingAnchor.constraint(equalTo: bubbleContainerView.leadingAnchor))
        constrains.append(highlightedEventView.trailingAnchor.constraint(equalTo: bubbleContainerView.trailingAnchor))
        constrains.append(highlightedEventView.topAnchor.constraint(equalTo: bubbleContainerView.topAnchor))
        constrains.append(eventsStackView.leadingAnchor.constraint(equalTo: bubbleContainerView.leadingAnchor, constant: margin))
        constrains.append(eventsStackView.trailingAnchor.constraint(equalTo: bubbleContainerView.trailingAnchor, constant: -margin))
        constrains.append(eventsStackView.bottomAnchor.constraint(equalTo: bubbleContainerView.bottomAnchor, constant: -margin / 2.0))
        constrains.append(eventStackViewTopConstraint)
        NSLayoutConstraint.activate(constrains)
        highlightedEventView.clickableText.delegate = self
    }
}

// MARK: UITextViewDelegate

extension MonthlyStatsEventScoreCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let delegate = self.delegate else {
            return false
        }
        delegate.shouldOpenSafariController(with: URL)
        return false
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.delegate = nil
        textView.selectedRange = NSRange(location: 0, length: 0)
        textView.delegate = self
    }
}
