import MessageUI
import UIKit
import Driving

// MARK: - DebugView

class DebugView: UIScrollView {
    let shareButton: StylingButton = {
        let button = StylingButton()
        button.titleLabel.text = "Share logs"
        return button
    }()

    lazy var recSwitchStack: UIStackView = {
        let label = UILabel()
        label.textColor = .negativePrimary
        label.text = "Rec"
        let switchStack = UIStackView()
        switchStack.addArrangedSubview(label)
        switchStack.addArrangedSubview(recordingSwitch)
        return switchStack
    }()

    lazy var recordingSwitch: UISwitch = {
        let recording = UISwitch()
        guard SygicDriving.sharedInstance().isInitialized else { return recording }
        recording.isOn = SygicDriving.sharedInstance().developerMode
        recording.addTarget(self, action: #selector(switchDeveloperMode(_:)), for: .touchUpInside)
        return recording
    }()

    let stackView: UIStackView = {
        let rootStack = UIStackView()
        rootStack.axis = .vertical
        rootStack.spacing = 2
        return rootStack
    }()

    private lazy var sdkStatusIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 10).isActive = true
        view.widthAnchor.constraint(equalToConstant: 10).isActive = true
        view.layer.cornerRadius = 5
        view.backgroundColor = SygicMapsInitializer.isSDKInitialized() ? .blue : .red2
        return view
    }()

    lazy var debugInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "DebugInfo:"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTrips()
        cover(with: stackView)
        widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTrips() {
        let sdkIndicatorContainer = UIView()
        sdkIndicatorContainer.addSubview(sdkStatusIndicator)
        sdkStatusIndicator.centerXAnchor.constraint(equalTo: sdkIndicatorContainer.centerXAnchor).isActive = true
        sdkStatusIndicator.topAnchor.constraint(equalTo: sdkIndicatorContainer.topAnchor).isActive = true
        sdkStatusIndicator.bottomAnchor.constraint(equalTo: sdkIndicatorContainer.bottomAnchor).isActive = true
        stackView.addArrangedSubview(sdkIndicatorContainer)
        stackView.addArrangedSubview(debugInfoLabel)
        stackView.addArrangedSubview(shareButton)
        stackView.addArrangedSubview(recSwitchStack)
        guard SygicDriving.sharedInstance().isInitialized else { return }
        if SygicDriving.sharedInstance().tripCount() > 0 {
            for tripIndex in 0 ..< SygicDriving.sharedInstance().tripCount() {
                stackView.addArrangedSubview(tripView(for: tripIndex))
            }
        }
    }

    private func setupStopPlayback() {
        let button = UIButton()
        button.setTitle("Stop playback", for: .normal)
        button.setTitleColor(.negativePrimary, for: .normal)
        button.addTarget(self, action: #selector(stopTripPlayback), for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }

    private func removeAllSubviews() {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    private func tripView(for tripId: Int) -> UIView {
        let button = UIButton()
        button.setTitle("Replay trip\(tripId)", for: .normal)
        button.setTitleColor(.actionPrimary, for: .normal)
        button.tag = tripId
        button.addTarget(self, action: #selector(playRecordedTrip(_:)), for: .touchUpInside)
        return button
    }

    @objc
private func switchDeveloperMode(_ sender: UISwitch) {
        guard SygicDriving.sharedInstance().isInitialized else { return }
        SygicDriving.sharedInstance().developerMode = sender.isOn
    }

    @objc
private func playRecordedTrip(_ sender: UIButton) {
        guard SygicDriving.sharedInstance().isInitialized else { return }
        SygicDriving.sharedInstance().replayTrip(at: sender.tag)
        removeAllSubviews()
        setupStopPlayback()
    }

    @objc
func stopTripPlayback() {
        guard SygicDriving.sharedInstance().isInitialized else { return }
        SygicDriving.sharedInstance().stopReplay()
        removeAllSubviews()
        setupTrips()
    }
}

// MARK: - DrivingViewController + MFMailComposeViewControllerDelegate

extension DrivingViewController: MFMailComposeViewControllerDelegate {
    @objc
func shareButtonPressed() {
        guard MFMailComposeViewController.canSendMail() else {
            let alertVC = UIAlertController(title: "No Email configured", message: "You need to configure at least one email account.", preferredStyle: .alert)
            let alertOkButtonAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertVC.addAction(alertOkButtonAction)
            present(alertVC, animated: true, completion: nil)
            return
        }

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self

        // Configure the fields of the interface.
        composeVC.setSubject("Trip log")
        composeVC.setMessageBody("Trip log.\n", isHTML: false)

        let path = sandboxStoragePath()
        let logPath = path + "log.txt"

        if let logData = NSData(contentsOfFile: logPath) {
            composeVC.addAttachmentData(logData as Data, mimeType: "text/plain", fileName: "log.txt")
        }
        self.present(composeVC, animated: true, completion: nil)
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func sandboxStoragePath() -> String {
        guard SygicDriving.sharedInstance().isInitialized else { return "" }
        if let sandbox = SygicDriving.sharedInstance().value(forKey: "sandbox"), let path = (sandbox as AnyObject).value(forKey: "currentSandBoxStoragePath") as? String {
            return path
        }
        return ""
    }
}
