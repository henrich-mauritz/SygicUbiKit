import Foundation
import UIKit

public class MonthlyStatsGraphTableViewCell: BubbleTableViewCell {
    private let kInnerMargins: UIEdgeInsets = UIEdgeInsets(top: 30, left: 20, bottom: -35, right: -20)

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textColor = .foregroundPrimary
        label.textAlignment = .left
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.textColor = .foregroundPrimary
        label.textAlignment = .left
        return label
    }()

    private lazy var bestDotIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .foregroundPrimary
        view.widthAnchor.constraint(equalToConstant: 6).isActive = true
        view.heightAnchor.constraint(equalToConstant: 6).isActive = true
        view.layer.cornerRadius = 3
        return view
    }()

    private lazy var graphStackView: UIStackView = {
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 320, height: 110))
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return stackView
    }()

    private lazy var weekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        return stackView
    }()

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 320, height: 302) //fix inital layout console logs
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        bubbleContainerView.addSubview(titleLabel)
        bubbleContainerView.addSubview(subtitleLabel)
        bubbleContainerView.addSubview(graphStackView)
        bubbleContainerView.addSubview(weekStackView)
        bubbleContainerView.addSubview(bestDotIndicator)

        var constrains: [NSLayoutConstraint] = []
        constrains.append(titleLabel.leadingAnchor.constraint(equalTo: bubbleContainerView.leadingAnchor, constant: kInnerMargins.left))
        constrains.append(titleLabel.trailingAnchor.constraint(equalTo: bubbleContainerView.trailingAnchor, constant: kInnerMargins.right))
        constrains.append(titleLabel.topAnchor.constraint(equalTo: bubbleContainerView.topAnchor, constant: kInnerMargins.top))
        constrains.append(bestDotIndicator.leadingAnchor.constraint(equalTo: bubbleContainerView.leadingAnchor, constant: kInnerMargins.left))
        constrains.append(bestDotIndicator.centerYAnchor.constraint(equalTo: subtitleLabel.centerYAnchor))
        constrains.append(subtitleLabel.leadingAnchor.constraint(equalTo: bestDotIndicator.trailingAnchor, constant: 5))
        constrains.append(subtitleLabel.trailingAnchor.constraint(equalTo: bubbleContainerView.trailingAnchor, constant: kInnerMargins.right))
        constrains.append(subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2))

        constrains.append(graphStackView.leadingAnchor.constraint(equalTo: bubbleContainerView.leadingAnchor, constant: kInnerMargins.left))
        constrains.append(graphStackView.trailingAnchor.constraint(equalTo: bubbleContainerView.trailingAnchor, constant: kInnerMargins.right))
        constrains.append(graphStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 17))

        constrains.append(weekStackView.leadingAnchor.constraint(equalTo: graphStackView.leadingAnchor, constant: 0))
        constrains.append(weekStackView.trailingAnchor.constraint(equalTo: graphStackView.trailingAnchor, constant: 0))
        constrains.append(weekStackView.topAnchor.constraint(equalTo: graphStackView.bottomAnchor, constant: 16))
        constrains.append(weekStackView.bottomAnchor.constraint(equalTo: bubbleContainerView.bottomAnchor, constant: kInnerMargins.bottom))
        NSLayoutConstraint.activate(constrains)
    }

    public func configureGraph(with dataSource: MonthlyStatsGraphDataSource, resetValues: Bool) {
        titleLabel.text = dataSource.title
        subtitleLabel.text = dataSource.subtitle

        configureGraph(with: dataSource)
        configureWeekStack(with: dataSource)

        if resetValues {
            graphStackView.subviews.forEach {
                if let barView = $0 as? MonthlyStatsBarView {
                    barView.prepareForAnimation()
                }
            }
        }

        for index in 0 ..< graphStackView.arrangedSubviews.count {
            guard let barView = graphStackView.arrangedSubviews[index] as? MonthlyStatsBarView else {
                return
            }
            let barType = dataSource.barTypeForDay(at: index)
            barView.viewModel = barType
        }

        for index in 0 ..< weekStackView.arrangedSubviews.count {
            guard let weekBubbleView = weekStackView.arrangedSubviews[index] as? MonthlyStatsWeekBubbleView else {
                return
            }
            weekBubbleView.titleLabel.text = dataSource.subTitleForWeek(at: index)
        }
    }

    func invalidateLayout() {
        graphStackView.subviews.forEach {
            graphStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        weekStackView.subviews.forEach {
            weekStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    private func configureGraph(with dataSource: MonthlyStatsGraphDataSource) {
        if graphStackView.subviews.count == 0 {
            for _ in 0 ..< dataSource.numberOfDays {
                let barView = MonthlyStatsBarView()
                graphStackView.addArrangedSubview(barView)
            }
            graphStackView.addArrangedSubview(UIView())
        }
    }

    private func configureWeekStack(with dataSource: MonthlyStatsGraphDataSource) {
        if weekStackView.subviews.count == 0 {
            for index in 0 ..< 4 {
                let weekView = MonthlyStatsWeekBubbleView()
                weekStackView.addArrangedSubview(weekView)
                weekView.titleLabel.text = dataSource.subTitleForWeek(at: index)
            }
        }
    }
}
