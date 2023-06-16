import Swinject
import UIKit

// MARK: - TriplogEventDetailView

public class TriplogEventDetailView: UIView, TriplogEventDetailViewProtocol, InjectableType {
    public weak var delegate: TriplogEventDetailViewDelegate?

    public var viewModel: TriplogEventDetailViewModelProtocol? {
        didSet {
            guard let viewModel = viewModel else { return }
            if viewModel.eventCanBeReported && viewModel.alreadyReported == nil {
                let cellView = ReportButtonView(frame: CGRect(x: 0, y: 0, width: 300, height: 64))
                cellView.button.addTarget(self, action: #selector(reportButtonAction), for: .touchUpInside)
                tableView.tableFooterView = cellView
            } else if let reported = viewModel.alreadyReported, reported == true {
                tableView.tableFooterView = alreadyReportedView
            }
            setNeedsLayout()
        }
    }

    lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.tableFooterView = UIView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = false
        return table
    }()

    private lazy var alreadyReportedView: UIView = {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 64))
        let label: UILabel = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.text = "triplog.tripDetailScore.alreadyReportedTitle".localized
        view.cover(with: label, insets: NSDirectionalEdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
        return view
    }()

    public required init() {
        super.init(frame: .zero)
        setupConstraints()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        cover(with: tableView)
    }

    @objc
private func reportButtonAction() {
        delegate?.shouldShowReportView()
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension TriplogEventDetailView: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        switch section {
        case 0:
            return 1
        default:
            return viewModel.eventType == .speeding ? 3 : 0
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        BasicTableViewCell.cellHeight
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = viewModel?.eventDetail,
            let name = viewModel?.eventType.formatedEventDetailString() else { return UITableViewCell() }

        if indexPath.section == 0 {
            let cell = DetailSelectionEventScoreCell()
            cell.hideSeparator = false
            cell.update(with: name, severnity: data.severityLevel, time: data.timestamp.hourInDayFormat())
            return cell
        } else {
            if viewModel?.eventType == .speeding {
                return tableViewForSpeedingCells(indexPath: indexPath)
            }
        }
        return UITableViewCell()
    }

    private func tableViewForSpeedingCells(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = container.resolve(TripDetailCellProtocol.self) else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            cell.leftLabel.text = "triplog.tripDetailScore.averageSpeed".localized
            cell.rightLabel.text = "\(Int(viewModel?.eventDetail.averageSpeed ?? 0)) km/h"
        case 1:
            cell.leftLabel.text = "triplog.tripDetailScore.maxSpeed".localized
            cell.rightLabel.text = "\(Int(viewModel?.eventDetail.maxSpeed ?? 0)) km/h"
        case 2:
            cell.leftLabel.text = "triplog.tripDetailScore.speedLimit".localized
            cell.rightLabel.text = "\(Int(viewModel?.eventDetail.speedLimit ?? 0)) km/h"
        default:
            return UITableViewCell()
        }
        return cell
    }
}
