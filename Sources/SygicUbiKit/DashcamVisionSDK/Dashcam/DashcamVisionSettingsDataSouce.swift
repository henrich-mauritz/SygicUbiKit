import Foundation
import MessageUI
import VisionLib

// MARK: - DashcamVisionSettingsDataSouce

public class DashcamVisionSettingsDataSouce: DashcamSettingsDataSource {
    private let kShareLogsType = "shareLogsType"
    override public var section1: [DashcamDisclosureCellModel] {
        return super.section1
    }

    override public var section2: [DashcamSwitchCellModel] {
        var settings = super.section2

        let container = SYInjector.container
        if let dashcamConfig = container.resolve(DashcamVisionConfigurable.self),
           dashcamConfig.signRecognitionEnabled {
            settings.append(DashcamSwitchCellModel(title: "vision.tailgatingNotificaiton.title".localized, subtitle: "vision.tailgatingNotificaiton.subtitle".localized,
                                                   isOn: UserDefaults.dashcamTailgatingNotification,
                                                   type: .customValue(UserDefaults.Keys.dashcamTailgatingNotification)))
        }
        return settings
    }

    override public func set(value isOn: Bool, for cellType: DashcamSwitchCellModel.CellType, onCell cell: DashcamSwitchCell) {
        super.set(value: isOn, for: cellType, onCell: cell)
        switch cellType {
        case let .customValue(val):
            if val == UserDefaults.Keys.dashcamTailgatingNotification {
                UserDefaults.setDashcamTailgatingNotification(isOn)
            }
        default:
            print("cell type not defined for this data source")
        }
    }

    override public func selectedCell(for type: DashcamDisclosureCellModel.CellType, on presentationController: UIViewController) {
        switch type {
        case let .customType(value):
            if value == kShareLogsType {
                settingsSelectedDashcamContact(from: presentationController)
            }
        default:
            break
        }
    }

    /// This method is just for debuging our demo app.
    private func settingsSelectedDashcamContact(from presentationController: UIViewController) {
        if MFMailComposeViewController.canSendMail() {
            DispatchQueue.global(qos: .userInitiated).async {
                let data = SYVision.shared().log().serialize()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    let composeController = MFMailComposeViewController()
                    composeController.mailComposeDelegate = self
                    composeController.setToRecipients(["jadamec@sygic.com"])
                    composeController.setSubject("Vision logs")
                    composeController.navigationBar.tintColor = .actionPrimary
                    composeController.addAttachmentData(data, mimeType: "application/json", fileName: "vision.log")
                    presentationController.present(composeController, animated: true, completion: nil)
                }
            }
        } else {
            // Show somethign maybe
            let alert = UIAlertController(title: "Not possible", message: "email client isn't configured in this device", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            presentationController.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: MFMailComposeViewControllerDelegate

extension DashcamVisionSettingsDataSouce: MFMailComposeViewControllerDelegate {
    @nonobjc public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
