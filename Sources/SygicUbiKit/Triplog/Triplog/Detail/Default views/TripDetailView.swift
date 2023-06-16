import MapKit
import Swinject
import UIKit

// MARK: - TripDetailView

public class TripDetailView: StylingBaseView, TripDetailViewProtocol, InjectableType {
    public weak var delegate: TripDetailWithMapViewControllerDelegate? {
        didSet {
            mapView?.delegate = delegate
        }
    }

    public var viewModel: TripDetailViewModelProtocol? {
        didSet {
            tableView.reloadData()
            showActivityIndicator(viewModel?.loading ?? false)
            guard let coordinates = viewModel?.coordinates else { return }
            mapView?.addPolyline(with: coordinates)
            mapView?.setVisibleArea(coordinates: coordinates, margins: UIEdgeInsets(top: 100, left: 25, bottom: 100, right: 25), animated: false)
            setupVisuals()
        }
    }
    //
    public lazy var mapView: TriplogMapViewProtocol? = {
        guard let view = container.resolve(TriplogMapViewProtocol.self) else { return nil }
        topContent.insertSubview(view, at: 0)
        topContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:))))
        return view
    }()
    
    public lazy var renderedMapImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        topContent.insertSubview(v, at: 0)
        v.isHidden = true
        return v
        
    }()

    override public init(frame: CGRect) {
        super.init(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        mapIndicator.isHidden = true
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        guard let footerView = self.tableView.tableFooterView else { return }
        let width = self.tableView.bounds.size.width
        let size = footerView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            self.tableView.tableFooterView = footerView
        }
    }

    private func setupVisuals() {
        guard let coordinates = viewModel?.coordinates else { return }
        mapView?.removeAllMapObjects()
        mapView?.addPolyline(with: coordinates)
        mapIndicatorShow()
        addAllEventPinsOnMap()
        mapView?.addStartEndPinsOnMap(coordinates: viewModel?.coordinates)
    }

    private func setupConstraints() {
        guard let mapView = mapView else { return }
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        //map
        var constraints = [mapView.leadingAnchor.constraint(equalTo: topContent.leadingAnchor)]
        constraints.append(mapView.trailingAnchor.constraint(equalTo: topContent.trailingAnchor))
        constraints.append(mapView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(mapView.bottomAnchor.constraint(equalTo: topContent.bottomAnchor))
        //image
        constraints.append(renderedMapImageView.leadingAnchor.constraint(equalTo: topContent.leadingAnchor))
        constraints.append(renderedMapImageView.trailingAnchor.constraint(equalTo: topContent.trailingAnchor))
        constraints.append(renderedMapImageView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(renderedMapImageView.bottomAnchor.constraint(equalTo: topContent.bottomAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }

    private func addAllEventPinsOnMap() {
        guard let events = viewModel?.eventTableData else { return }
        for event in events {
            guard let eventViewModel = viewModel?.getEventsData(for: event.eventType), let items = eventViewModel.items else { continue }
            mapView?.addEventPins(with: eventViewModel.type, items: items, withPolyline: true, animated: true)
        }
    }
    
    public func replaceMapWithRenderedImage(image: UIImage) {
        renderedMapImageView.image = image
        renderedMapImageView.isHidden = false
        mapView?.removeFromSuperview()
        topContent.sendSubviewToBack(renderedMapImageView)
    }

    @objc
private func mapTapped(_ sender: Any) {
        guard viewModel?.coordinates != nil else { return }
        delegate?.shouldShowScoreDetail()
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension TripDetailView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        switch section {
        case 0, 2:
            return 1
        case 1:
            return viewModel.mapTableData.count
        default:
            return 0
        }
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 124
        } else {
            return BasicTableViewCell.cellHeight
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = viewModel else { return UITableViewCell() }
        return tableViewCellForMapState(indexPath: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            delegate?.showAboutYourScore()
        } else {
            delegate?.shouldShowScoreDetail()
        }
    }

    private func tableViewCellForMapState(indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }

        switch indexPath.section {
        case 0:
            guard let cell = container.resolve(TripDetailAddressCellProtocol.self) else { return UITableViewCell() }
            cell.startAddress.text = viewModel.fromLocationName != "" ? viewModel.fromLocationName : "triplog.tripDetail.unknownLocation".localized
            cell.endAddress.text = viewModel.toLocationName != "" ? viewModel.toLocationName : "triplog.tripDetail.unknownDestination".localized
            cell.startDate.text = viewModel.startTime.hourInDayFormat()
            cell.endDate.text = viewModel.endTime.hourInDayFormat()
            return cell
        case 1:
            var basicCell: TripDetailCellProtocol?
            if indexPath.row == 0 {
                basicCell = container.resolve(TripDetailScoreCellProtocol.self)
            } else {
                basicCell = container.resolve(TripDetailCellProtocol.self)
                basicCell?.isUserInteractionEnabled = false
            }

            guard let cell = basicCell else { return UITableViewCell() }
            cell.leftLabel.text = viewModel.mapTableData[indexPath.row].name
            cell.rightLabel.text = viewModel.mapTableData[indexPath.row].description
            if indexPath.row == 0 {
                cell.rightLabel.font = .stylingFont(.thin, with: 30)
            }
            return cell
        case 2:
            guard let aboutScoreCell = container.resolve(TripDetailScoreCellProtocol.self) else {
                return UITableViewCell()
            }
            aboutScoreCell.isUserInteractionEnabled = true
            aboutScoreCell.leftLabel.text = "triplog.tripDetail.aboutDrivescore".localized
            return aboutScoreCell
        default:
            return UITableViewCell()
        }
    }
}
