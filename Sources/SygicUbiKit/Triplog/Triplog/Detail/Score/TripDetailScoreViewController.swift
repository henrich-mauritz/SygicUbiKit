import Foundation
import UIKit
import Swinject

// MARK: - TripDetailScoreViewController

public class TripDetailScoreViewController: UITableViewController, InjectableType {
    public var viewModel: TripDetailViewModelProtocol? {
        didSet {
            tableView.reloadData()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        title = "triplog.tripDetailScore.tripScoreTitle".localized
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let vehicle = viewModel?.currentFilteringVehicle, let parentController = parent?.parent else { return }
        let indicatorView = VPVehicleIndicatorView(frame: .zero)
        indicatorView.update(with: vehicle.name.uppercased(), textColor: .buttonForegroundTertiaryPassive, backgroundColor: .buttonBackgroundTertiaryPassive)
        parentController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicatorView)
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        switch section {
        case 0:
            return 1
        default:
            if viewModel.isPerfectTrip {
                return 0
            }
            return viewModel.eventTableData.count
        }
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let viewModel = viewModel, viewModel.isPerfectTrip, indexPath.section == 0 {
            return CongratulationsViewCell.cellHeight
        }
        return BasicTableViewCell.cellHeight
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        if viewModel.isPerfectTrip {
            guard let cell = container.resolve(TripCongratulationsViewCellProtocol.self) else { return UITableViewCell() }
            cell.viewModel = viewModel.getCongratulationsViewModel()
            return cell
        } else {
            return tableViewCellForScoreState(indexPath: indexPath)
        }
    }

    override public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let viewModel = viewModel else { return false }
        if viewModel.isPerfectTrip || indexPath.section == 0 {
            return false
        }
        return true
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let viewModel = viewModel else { return }
        if viewModel.isPerfectTrip || indexPath.section == 0 {
            return
        }
        let event = viewModel.eventTableData[indexPath.row]
        shouldShowDetail(eventType: event.eventType)
    }

    private func tableViewCellForScoreState(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = container.resolve(TripDetailCellProtocol.self) else { return UITableViewCell() }
            cell.leftLabel.text = "triplog.tripDetailScore.tripScore".localized
            cell.leftLabel.font = .stylingFont(.bold, with: 16)
            cell.rightLabel.text = viewModel?.overallScore
            cell.rightLabel.font = .stylingFont(.thin, with: 30)
            cell.separatorView.isHidden = false
            return cell
        case 1:
            guard let cell = container.resolve(TripDetailScoreCellProtocol.self),
                    let event = viewModel?.eventTableData[indexPath.row] else { return UITableViewCell() }
            cell.leftLabel.text = event.formattedEventName
            cell.rightLabel.text = event.formattedScore
            cell.iconColor = event.color
            return cell
        default:
            return UITableViewCell()
        }
    }

    private func shouldShowDetail(eventType: EventType) {
        guard let partialScoreViewModel = viewModel?.getPartialScoreViewModel(for: eventType),
            let destination = container.resolve(TripDetailPartialScoreViewController.self) else { return }
        destination.viewModel = partialScoreViewModel
        guard let mapViewController = container.resolve(TriplogMapViewController.self) else { return }
        mapViewController.mapViewModel = partialScoreViewModel.mapViewModel
        mapViewController.contentController = destination
        navigationController?.pushViewController(mapViewController, animated: true)
    }
}

// MARK: FloatingPanelContentController

extension TripDetailScoreViewController: FloatingPanelContentController {
    public var trackableScrollView: UIScrollView? {
        tableView
    }
}
