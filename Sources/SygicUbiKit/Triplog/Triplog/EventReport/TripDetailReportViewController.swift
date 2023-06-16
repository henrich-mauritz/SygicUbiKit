import Swinject
import UIKit

// MARK: - TripDetailReportViewController

public class TripDetailReportViewController: UIViewController, TripDetailReportViewControllerProtocol {
    public var viewModel: TripDetailReportViewModelProtocol?

    public weak var delegate: TripDetailReportViewControllerDelegate?

    public weak var container: Container?

    override public func loadView() {
        let reportView = container?.resolve(TripDetailReportViewProtocol.self)
        reportView?.viewModel = viewModel
        reportView?.delegate = self
        view = reportView
    }
}

// MARK: TripDetailReportViewDelegate

extension TripDetailReportViewController: TripDetailReportViewDelegate {
    public func wrongInput() {
        let alert = UIAlertController(title: "triplog.reportAlert.title".localized, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "triplog.reportAlert.button".localized.uppercased(), style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    public func reportCanceled() {
        dismiss(animated: true, completion: nil)
    }

    public func reportSubmited(result: Result<Bool, Error>) {
        delegate?.reportSubmited(result: result)
    }
}
