import AVFoundation
import UIKit

// MARK: - DashcamSettingsDatasouceType

public protocol DashcamSettingsDatasouceType {
    var section1: [DashcamDisclosureCellModel] { get }
    var section2: [DashcamSwitchCellModel] { get }
    func set(value isOn: Bool,
             for cellType: DashcamSwitchCellModel.CellType,
             onCell cell: DashcamSwitchCell)
    func selectedCell(for type: DashcamDisclosureCellModel.CellType,
                      on presentationController: UIViewController)
}

// MARK: - DashcamSettingsDataSource

open class DashcamSettingsDataSource: NSObject, DashcamSettingsDatasouceType {
    open var section1: [DashcamDisclosureCellModel] {
        [
            DashcamDisclosureCellModel(title: "dashcam.settings.videoQualityTitle".localized,
                                       subtitle: (VideoQuality(rawValue: UserDefaults.dashcamVideoQuality) ?? .SD).localizedText,
                                       description: nil,
                                       type: .quality),
            DashcamDisclosureCellModel(title: "dashcam.video.duration".localized,
                                       subtitle: (VideoDuration(rawValue: UserDefaults.dashcamVideoDuration) ?? .min1).localizedText,
                                       description: "dashcam.settings.durationSubtitle".localized,
                                       type: .duration),
        ]
    }

    open var section2: [DashcamSwitchCellModel] {
        var settings = [
            DashcamSwitchCellModel(title: "dashcam.settings.crashTitle".localized, subtitle: "dashcam.settings.crashSubtitle".localized, isOn: UserDefaults.dashcamCrashDetector, type: .crashDetector),
        ]

        settings.append(DashcamSwitchCellModel(title: "dashcam.settings.recordSoundTitle".localized, subtitle: "dashcam.settings.recordSoundSubtitle".localized,
                                               isOn: UserDefaults.dashcamSoundEnabled,
                                               type: .recordSound))
        return settings
    }

    override public init() {}

    open func set(value isOn: Bool,
                  for cellType: DashcamSwitchCellModel.CellType,
                  onCell cell: DashcamSwitchCell) {
        switch cellType {
        case .oneTapRecording:
            UserDefaults.setDashcamOneTap(isOn)
        case .automaticRecording:
            UserDefaults.setDashcamAutomaticRecording(isOn)
        case .recordSound:
            switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .authorized:
                UserDefaults.setDashcamSoundEnabled(isOn)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .audio) { access in
                    UserDefaults.setDashcamSoundEnabled(access)
                    DispatchQueue.main.async {
                        cell.switchView.isOn = access
                    }
                }
            default:
                cell.switchView.isOn = false
                UserDefaults.setDashcamSoundEnabled(false)
            }
        case .videoOverlay:
            UserDefaults.setDashcamShouldShowOverlay(isOn)
        case .crashDetector:
            UserDefaults.setDashcamCrashDetector(isOn)
        case let .customValue(val):
            if ADASDebug.enabled {
                print("This data source doesn't implement the given type \(val)")
            }
        }
    }

    open func selectedCell(for type: DashcamDisclosureCellModel.CellType, on presentationController: UIViewController) {}
}

// MARK: - DashcamSettingsViewController

public final class DashcamSettingsViewController: UIViewController {
    var willDismiss: VoidBlock?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let dataSource: DashcamSettingsDatasouceType

    private var quality: VideoQuality {
        VideoQuality(rawValue: UserDefaults.dashcamVideoQuality) ?? .SD
    }

    private var duration: VideoDuration {
        VideoDuration(rawValue: UserDefaults.dashcamVideoDuration) ?? .min1
    }

    init(_ tableDataSource: DashcamSettingsDatasouceType) {
        dataSource = tableDataSource
        super.init(nibName: nil, bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DashcamSwitchCell.self, forCellReuseIdentifier: NSStringFromClass(DashcamSwitchCell.self))
        tableView.register(DashcamDisclosureCell.self, forCellReuseIdentifier: NSStringFromClass(DashcamDisclosureCell.self))
    }

    public convenience init(isDarkTheme: Bool, _ dataSource: DashcamSettingsDatasouceType) {
        DashcamColorManager.shared.setTheme(dark: isDarkTheme)
        self.init(dataSource)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "dashcam.settings.title".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        setupUI()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        willDismiss?()
    }
}

extension DashcamSettingsViewController {
    func addNavigationBarItems() {
        let item = UIBarButtonItem(title: "dashcam.settings.close".localized, style: .done, target: self, action: #selector(close))
        item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: DashcamColorManager.shared.blue], for: .normal)
        navigationItem.rightBarButtonItem = item
    }
}

// MARK: Private

private extension DashcamSettingsViewController {
    @objc func close() {
        dismiss(animated: true)
    }

    func setupUI() {
        tableView.backgroundColor = .backgroundPrimary
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .backgroundSecondary
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        view.addAutoLayoutSubviews(tableView)
        tableView.coverWholeSuperview()
    }

    func showPicker(with viewModel: DashcamPickerViewModelProtocol) {
        let pickerVC = DashcamPickerViewController(with: viewModel, delegate: self)
        pickerVC.modalPresentationStyle = .overFullScreen
        present(pickerVC, animated: true)
    }

    func showVideoDurationSettings() {
        showPicker(with: DashcamPickerViewModel(with: DashcamHelpers.availableDashcamVideoDurationOptions(), pickerType: .duration, selectedOption: (duration.rawValue, "")))
    }

    func showVideoQualitySettings() {
        showPicker(with: DashcamPickerViewModel(with: DashcamHelpers.availableDashcamVideoQualityOptions(), pickerType: .quality, selectedOption: (quality.rawValue, "")))
    }

    func showSettingsAlert() {
        let modalVC = DashcamPermissionsModalViewController(soundPermisson: true)
        PopupManager.shared.presentModalPopup(modalVC, on: self)
    }
}

// MARK: UITableViewDataSource

extension DashcamSettingsViewController: UITableViewDataSource {
    public func numberOfSections(in _: UITableView) -> Int { 2 }

    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dataSource.section1.count
        }

        return dataSource.section2.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0, let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DashcamDisclosureCell.self), for: indexPath) as? DashcamDisclosureCell {
            cell.configure(with: dataSource.section1[indexPath.row])

            return cell
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DashcamSwitchCell.self), for: indexPath) as? DashcamSwitchCell {
            cell.delegate = self
            cell.configure(with: dataSource.section2[indexPath.row])

            return cell
        }

        assertionFailure()
        return UITableViewCell()
    }

    public func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let header = UIView()
        return header
    }

    public func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 16 : 0
    }
}

// MARK: UITableViewDelegate

extension DashcamSettingsViewController: UITableViewDelegate {
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let type = dataSource.section1[indexPath.row].type
            switch type {
            case .duration:
                showVideoDurationSettings()
            case .quality:
                showVideoQualitySettings()
            case .customType(_):
                self.dataSource.selectedCell(for: type, on: self)
            }
        }
    }

    public func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: DashcamSwitchCellDelegate

extension DashcamSettingsViewController: DashcamSwitchCellDelegate {
     func switchDidChange(isOn: Bool, cell: DashcamSwitchCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return assertionFailure() }
        let type = dataSource.section2[indexPath.row].type
        dataSource.set(value: isOn, for: type, onCell: cell)
        switch type {
        case .recordSound:
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            if status != .notDetermined && status != .authorized {
                showSettingsAlert()
            }
        case .customValue("dashcamTailgatingNotification"):
            UserDefaults.standard.set(isOn, forKey: "dashcamTailgatingNotification")
        default:
            print("do nothing")
        }
    }
}

// MARK: DashcamOnboardingPickerDelegate

extension DashcamSettingsViewController: DashcamOnboardingPickerDelegate {
    func didSelect(option: DashcamOption, pickerType: DashcamOnboardingPickerType) {
        switch pickerType {
        case .duration:
            let value = VideoDuration(rawValue: option.optionToSave) ?? .min1
            UserDefaults.setDashcamVideoDuration(value)
        case .quality:
            let value = VideoQuality(rawValue: option.optionToSave) ?? .HD
            UserDefaults.setDashcamVideoQuality(value)
        }
        tableView.reloadData()
    }
}
