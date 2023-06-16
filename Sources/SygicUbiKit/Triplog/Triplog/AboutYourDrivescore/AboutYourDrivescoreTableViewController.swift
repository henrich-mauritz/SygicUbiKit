import UIKit


// MARK: - AboutYourDrivescoreType

struct AboutYourDrivescoreType {
    let header: String
    var infoItems: [DriveScoreInfoType]
    let headerValue: String
}

struct DriveScoreInfoType {
    let title: String
    let descr: String
    let image: String?
    var isExpanded: Bool
    let showArrow: Bool
}

struct PendingTripMockViewModel: PendingTripType {
    var id: String
    var startTime: Date
    var endTime: Date
    var locationStartName: String
    var locationEndName: String
    var distanceKm: Double
    var vehiclePublicId: String? { return nil }
    
    init(id: String, startTime: Date, endTime: Date, locationStartName: String, locationEndName: String, distanceKm: Double) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.locationStartName = locationStartName
        self.locationEndName = locationEndName
        self.distanceKm = distanceKm
    }
}

public class AboutYourDrivescoreTableViewController: UITableViewController {
    lazy var viewModel: AboutYourDrivescoreType = {
        var driveScoreInfoTypes: [DriveScoreInfoType] = []
        driveScoreInfoTypes.append(DriveScoreInfoType(title: "triplog.aboutDrivescore.accelerationTitle".localized,
                                                      descr: "triplog.aboutDrivescore.accelerationDescription".localized,
                                                      image: nil,
                                                      isExpanded: false,
                                                      showArrow: true))
        
        driveScoreInfoTypes.append(DriveScoreInfoType(title: "triplog.aboutDrivescore.brakingTitle".localized,
                                                      descr: "triplog.aboutDrivescore.brakingDescription".localized,
                                                      image: nil,
                                                      isExpanded: false,
                                                      showArrow: true))
        
        driveScoreInfoTypes.append(DriveScoreInfoType(title: "triplog.aboutDrivescore.corneringTitle".localized,
                                                      descr: "triplog.aboutDrivescore.corneringDescription".localized,
                                                      image: nil,
                                                      isExpanded: false,
                                                      showArrow: true))
        
        driveScoreInfoTypes.append(DriveScoreInfoType(title: "triplog.aboutDrivescore.speedingTitle".localized,
                                                      descr: "triplog.aboutDrivescore.speedingDescription".localized,
                                                      image: nil,
                                                      isExpanded: false,
                                                      showArrow: true))
        
        if vehicleType != .motorcycle {
            driveScoreInfoTypes.append(DriveScoreInfoType(title: "triplog.aboutDrivescore.distractionTitle".localized,
                                                          descr: "triplog.aboutDrivescore.distractionDescription".localized,
                                                          image: nil,
                                                          isExpanded: false,
                                                          showArrow: true))
        }
        driveScoreInfoTypes.append(DriveScoreInfoType(title: "triplog.aboutDrivescore.wereYouDrivingTitle".localized,
                                                      descr: "triplog.aboutDrivescore.wereYouDrivingDescription".localized,
                                                      image: "", 
                                                      isExpanded: true,
                                                      showArrow: false))
        
        return AboutYourDrivescoreType(header: "",
                                       infoItems: driveScoreInfoTypes,
                                       headerValue: "triplog.aboutDrivescore.subtitle".localized)
    }()

    private let dummyTripModel: PendingTripCellPresentable = PendingTripCellViewModel(pendingTrip: PendingTripMockViewModel(id: "",
                                                                                                                            startTime: Date(timeIntervalSince1970: 1594383600),
                                                                                                                            endTime: Date(timeIntervalSince1970: 1594394400),
                                                                                                                            locationStartName: "triplog.aboutDrivescore.wereYouDrivingCity".localized,
                                                                                                                            locationEndName: "triplog.aboutDrivescore.wereYouDrivingCity".localized,
                                                                                                                            distanceKm: 100))
    public var vehicleType: VehicleType
    
    public init(vehicleType: VehicleType) {
        self.vehicleType = vehicleType
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        navigationController?.navigationBar.sizeToFit()
    }

    private func configureUI() {
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        title = "triplog.aboutDrivescore.title".localized
        navigationItem.largeTitleDisplayMode = .always
        tableView.backgroundColor = .backgroundPrimary
        tableView.separatorStyle = .none
        tableView.register(AboutYourScoreTableViewCell.self, forCellReuseIdentifier: AboutYourScoreTableViewCell.identifier)
        tableView.register(AboutYourScoreDescriptionTableViewCell.self, forCellReuseIdentifier: AboutYourScoreDescriptionTableViewCell.identifier)
        tableView.register(PendingTripTableViewCell.self, forCellReuseIdentifier: PendingTripTableViewCell.identifier)
    }

    private func layoutHeaderView() {
        //Setting the header
        let header = AboutYourScoreHeaderView(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        header.update(title: viewModel.headerValue)
        header.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = header
        header.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        header.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        header.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        header.layoutIfNeeded()
        tableView.tableHeaderView = tableView.tableHeaderView //hack here but is force to recalculate layout
        tableView.layoutIfNeeded()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let isNavbarHidden = navigationController?.isNavigationBarHidden, isNavbarHidden == true {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        layoutHeaderView()
    }

    // MARK: - Table view data source

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.infoItems.count
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let infoItem = viewModel.infoItems[section]
        if infoItem.isExpanded {
            if infoItem.image != nil {
                return 3
            }
            return 2
        }
        return 1
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.infoItems[indexPath.section]
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: AboutYourScoreTableViewCell.identifier, for: indexPath) as? AboutYourScoreTableViewCell {
                cell.update(with: item)
                return cell
            }
        }

        if item.image != nil {
            if indexPath.row == 1 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: PendingTripTableViewCell.identifier, for: indexPath) as? PendingTripTableViewCell {
                    cell.update(with: dummyTripModel)
                    cell.isUserInteractionEnabled = false
                    return cell
                }
            }
        }

        //The rest
        if let cell = tableView.dequeueReusableCell(withIdentifier: AboutYourScoreDescriptionTableViewCell.identifier, for: indexPath) as? AboutYourScoreDescriptionTableViewCell {
            cell.update(with: item.descr)
            return cell
        }

        return UITableViewCell()
    }

    private func insertDescription(at indexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .top)
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPaths.first!, at: .middle, animated: true)
    }

    private func removeDescription(at indexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPaths, with: .top)
        tableView.endUpdates()
    }

    //MARK: - TableView Delegate

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.infoItems[indexPath.section]
        if item.showArrow == false {
            return
        }

        guard let cell = tableView.cellForRow(at: indexPath) as? AboutYourScoreTableViewCell else {
            return
        }
        viewModel.infoItems[indexPath.section].isExpanded.toggle()
        let expanded = !item.isExpanded
        cell.toggleState(expanded: expanded, animated: true)

        if expanded {
            insertDescription(at: [IndexPath(row: 1, section: indexPath.section)])
        } else {
            removeDescription(at: [IndexPath(row: 1, section: indexPath.section)])
        }
    }
}
