import MapKit
import Swinject
import UIKit

// MARK: - TripDetailPartialScoreView

public class TripDetailPartialScoreView: UIView, TripDetailPartialScoreViewProtocol, InjectableType {
    public weak var delegate: TripDetailPartialScoreViewDelegate?

    public var viewModel: TripDetailPartialScoreViewModelProtocol?

    lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.tableFooterView = UIView()
        table.dataSource = self
        table.delegate = self
        return table
    }()

    public required init() {
        super.init(frame: .zero)
        setupConstraints()
        backgroundColor = .backgroundModal
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        cover(with: tableView)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension TripDetailPartialScoreView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = viewModel?.events else { return 0 }
        return section == 0 ? 1 : items.count
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let viewModel = viewModel, viewModel.isPerfectScore {
            return CongratulationsViewCell.cellHeight
        }
        return BasicTableViewCell.cellHeight
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        if viewModel.isPerfectScore {
            guard let cell = container.resolve(TripCongratulationsViewCellProtocol.self) else { return UITableViewCell() }
            cell.viewModel = viewModel.getCongratulationsViewModel()
            return cell
        }
        if indexPath.section == 0 {
            guard let cell = container.resolve(TripDetailCellProtocol.self) else { return UITableViewCell() }
            cell.leftLabel.text = viewModel.scoreDescription
            cell.rightLabel.text = viewModel.score
            cell.rightLabel.font = .stylingFont(.thin, with: 30)
            cell.leftLabel.font = .stylingFont(.bold, with: 16)
            cell.separatorView.isHidden = false
            return cell
        } else {
            let event = viewModel.events[indexPath.row]
            guard let cell = container.resolve(TripDetailPartialScoreEventCellProtocol.self) else { return UITableViewCell() }
            let str = event.timestamp.hourInDayFormat()
            cell.update(with: str, severnity: event.severityLevel, time: nil)
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1,
            let event = viewModel?.events[indexPath.row],
            let eventType = viewModel?.eventType else { return }
        delegate?.shouldShowPartialEventDetail(eventType: eventType, event: event)
    }
}
