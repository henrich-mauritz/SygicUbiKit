import UIKit

// MARK: - DrivingResultViewController

class DrivingResultViewController: UIViewController {
    public var viewModel: DrivingResultViewModel!

    private let items = [
        "driving.summary.tripDuration".localized,
        "driving.summary.tripDistance".localized,
    ]

    private var values: [String] {
        [
            viewModel.duration,
            viewModel.distanceTravelled,
        ]
    }

    private lazy var doneButton: StylingButton = {
        let button = StylingButton.button(with: .tertiary)
        button.titleLabel.text = "driving.summary.okButton".localized.uppercased()
        return button
    }()

    private var statusView: DrivingStatusView = DrivingStatusView()

    private var doneButtonLeadingConstraint: NSLayoutConstraint?
    private var doneButtonTrailingConstraint: NSLayoutConstraint?
    private var errorStateCenterYConstraint: NSLayoutConstraint?

    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(BasicTableViewCell.self, forCellReuseIdentifier: BasicTableViewCell.cellIdentifier)
        tableView.estimatedRowHeight = 56
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        tableView.separatorColor = UIColor.backgroundSecondary.darkStyle
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()

    private lazy var errorStateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 20)
        label.textColor = .foregroundDriving
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let elementMargin: CGFloat = 10.0
    private let staticMargin: CGFloat = 50.0
    private let statusMargin: CGFloat = 30.0
    private let statusHeight: CGFloat = 130.0
    private let buttonMargin: CGFloat = 63.0
    private let buttonHeight: CGFloat = 48.0
    private let buttonBottom: CGFloat = 30.0
    private let tableBottom: CGFloat = 46

    init(viewModel: DrivingResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(errorStateLabel)
        view.addSubview(statusView)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        initTableView()
        initConstraints()
        viewModelUpdated(viewModel)
        doneButton.addTarget(self, action: #selector(DrivingResultViewController.doneButtonPressed), for: .touchUpInside)
        view.backgroundColor = .backgroundDriving
    }

    @objc
private func doneButtonPressed() {
        viewModel.waitingForTripScoreFinished()
        dismiss(animated: true, completion: nil)
    }

    private func initTableView() {
        tableView.dataSource = self
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }

    private func initConstraints() {
        statusView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()

        constraints.append(errorStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: statusMargin))
        constraints.append(errorStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -statusMargin))
        errorStateCenterYConstraint = errorStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -3 * statusMargin)
        constraints.append(errorStateCenterYConstraint!)
        constraints.append(statusView.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor))
        constraints.append(statusView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: statusMargin))
        constraints.append(statusView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -statusMargin))
        constraints.append(statusView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -elementMargin))
        constraints.append(statusView.heightAnchor.constraint(greaterThanOrEqualToConstant: statusHeight))

        constraints.append(tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2 * elementMargin))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2 * elementMargin))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -tableBottom))
        constraints.append(tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height + 1))
        doneButtonLeadingConstraint = doneButton.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: buttonMargin)
        doneButtonTrailingConstraint = doneButton.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -buttonMargin)
        prepareConstraintsForCurrentOrientation()
        constraints.append(doneButtonLeadingConstraint!)
        constraints.append(doneButtonTrailingConstraint!)
        constraints.append(doneButton.heightAnchor.constraint(equalToConstant: buttonHeight))
        constraints.append(doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -buttonBottom))
        NSLayoutConstraint.activate(constraints)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        prepareConstraintsForCurrentOrientation()
    }

    private func prepareConstraintsForCurrentOrientation() {
        if UIDevice.current.orientation.isLandscape {
            doneButtonLeadingConstraint?.constant = 0
            doneButtonTrailingConstraint?.constant = 0
            if tableView.isHidden {
                errorStateCenterYConstraint?.constant = -staticMargin
            } else {
                errorStateCenterYConstraint?.constant = 2 * -staticMargin
            }

        } else if UIDevice.current.orientation.isPortrait {
            doneButtonLeadingConstraint?.constant = buttonMargin
            doneButtonTrailingConstraint?.constant = -buttonMargin
            if tableView.isHidden {
                errorStateCenterYConstraint?.constant = -staticMargin
            } else {
                errorStateCenterYConstraint?.constant = 3 * -staticMargin
            }
        }
    }
}

// MARK: UITableViewDataSource

extension DrivingResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BasicTableViewCell.cellIdentifier, for: indexPath) as! BasicTableViewCell
        let item = items[indexPath.item]
        let value = values[indexPath.item]
        cell.leftLabel.textColor = .foregroundDriving
        cell.rightLabel.textColor = .foregroundDriving
        cell.leftLabel.text = item
        cell.rightLabel.text = value
        return cell
    }
}

// MARK: DrivingResultViewModelDelegate

extension DrivingResultViewController: DrivingResultViewModelDelegate {
    func viewModelUpdated(_ viewModel: DrivingResultViewModel) {
        statusView.viewState = viewModel.viewState
        switch viewModel.viewState {
        case .offline:
            offlineState()
        case .timeOut:
            timeOutState()
        case let .error(reason: error):
            tableView.isHidden = true
            errorState(message: error.localizedMessage)
        default:
            errorStateLabel.isHidden = true
        }
        if case .error = viewModel.viewState { } else {
            tableView.reloadData()
            tableView.isHidden = false
        }
        registerAnalytic(for: viewModel.viewState)
    }

    private func registerAnalytic(for state: StatusState) {
        let analyticShowKey = AnalyticsKeys.drivingTripSummaryShow
        let analyticParameterKey = AnalyticsKeys.Parameters.tripSumaryKey
        switch state {
        case .tripScored(_):
            AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                        parameters: [analyticParameterKey: AnalyticsKeys.Parameters.scoreValue])
        case .offline:
            AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                        parameters: [analyticParameterKey: AnalyticsKeys.Parameters.offilineValue])
        case .timeOut:
            AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                        parameters: [analyticParameterKey: AnalyticsKeys.Parameters.timeoutValue])
        case let .error(reason):
            switch reason {
            case .invalidDurationTooShort:
                AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                            parameters: [analyticParameterKey: AnalyticsKeys.Parameters.tripDurationTooShortValue])
            case .invalidDistanceTooShort:
                AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                            parameters: [analyticParameterKey: AnalyticsKeys.Parameters.tripDistanceTooShortValue])
            case .fraudBehaviourDetected:
                AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                            parameters: [analyticParameterKey: AnalyticsKeys.Parameters.fraudBehaviourValue])
            case .invalidStartEnd:
                AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                            parameters: [analyticParameterKey: AnalyticsKeys.Parameters.invalidSystemTimeValue])
            case .invalidEvent:
                AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                            parameters: [analyticParameterKey: AnalyticsKeys.Parameters.invalidEvent])
            case .invalidInput:
                AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                            parameters: [analyticParameterKey: AnalyticsKeys.Parameters.invalidInput])
            case .unknown:
                AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                            parameters: [analyticParameterKey: AnalyticsKeys.Parameters.unknown])
            case .none:
                AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                            parameters: [analyticParameterKey: AnalyticsKeys.Parameters.none])
            case .uploadFailed:
                AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                            parameters: [analyticParameterKey: AnalyticsKeys.Parameters.uploadFailed])
            case .timePeriodProhibited:
                AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                            parameters: [analyticParameterKey: AnalyticsKeys.Parameters.timePeriodProhibited])
            default:
                AnalyticsRegisterer.shared.registerAnalytic(with: analyticShowKey,
                                                            parameters: [analyticParameterKey: AnalyticsKeys.Parameters.generalErrorValue])
            }
        default:
            print("No analytics to register on driving screen")
        }
    }

    private func offlineState() {
        if UIDevice.current.orientation.isLandscape {
            errorStateCenterYConstraint?.constant = 2 * -staticMargin
        }
        errorStateLabel.text = "driving.summary.resultTextOffline".localized
        errorStateLabel.isHidden = false
    }

    private func timeOutState() {
        if UIDevice.current.orientation.isLandscape {
            errorStateCenterYConstraint?.constant = 2 * -staticMargin
        }
        errorStateLabel.text = "driving.summary.resultTextInProgress".localized
        errorStateLabel.isHidden = false
    }

    private func errorState(message: String) {
        errorStateCenterYConstraint?.constant = -staticMargin
        errorStateLabel.text = message
        errorStateLabel.isHidden = false
    }
}
