import Foundation
import UIKit

// MARK: - BadgeDetailViewController

public class BadgeDetailViewController: UIViewController, InjectableType {
    var viewModel: BadgeViewModelDetailType?

    class func embeededController(with badgeId: String) -> UINavigationController {
        let detailController = BadgeDetailViewController(badgeId: badgeId)
        let navController = UINavigationController(rootViewController: detailController)
        navController.setupStyling()
        navController.modalPresentationStyle = .fullScreen
        return navController
    }

    public init(badgeId: String) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = container.resolve(BadgeViewModelDetailType.self, argument: badgeId)
        self.viewModel?.delegate = self
        modalPresentationStyle = .fullScreen
    }

    public required init?(coder: NSCoder) {
        fatalError("Not coder initialized supportedd")
    }

    override public func loadView() {
        let badgeView = BadgeDetailView(frame: .zero)
        self.view = badgeView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = self.viewModel else {
            return
        }
        viewModel.loadDetail()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "badges.close".localized, style: .plain,
                                                           target: self, action: #selector(BadgeDetailViewController.close))
        navigationController?.delegate = self
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let view = self.view as? BadgeDetailViewConfigurable else {
            return
        }
        view.viewModel = viewModel
    }

    @objc
private func close() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: BadgeDetailViewModelDelegate

extension BadgeDetailViewController: BadgeDetailViewModelDelegate {
    public func viewModelDidUpdate(viewModel: BadgeViewModelDetailType) {
        guard let view = self.view as? BadgeDetailViewConfigurable,
              let detail = viewModel.badgeDetail else {
            return
        }
        UserDefaults.standard.setValue(detail.currentLevel, forKey: "badge_\(viewModel.badgeId)_level")
        view.viewModel = viewModel
    }

    public func viewModelDidFail(viewModel: BadgeViewModelDetailType, error: Error) {}
}

// MARK: UINavigationControllerDelegate

extension BadgeDetailViewController: UINavigationControllerDelegate {
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        .portrait
    }
}
