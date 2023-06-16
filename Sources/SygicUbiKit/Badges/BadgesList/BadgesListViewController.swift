import Foundation
import UIKit

// MARK: - BadgesListViewController

public class BadgesListViewController: UIViewController, InjectableType {
    //MARK: - Properties

    public var viewModel: BadgesListViewModelType? {
        didSet {
            guard let view = view as? BadgesListViewType else {
                return
            }
            view.viewModel = viewModel
        }
    }

    //MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override public func loadView() {
        guard let badgesView = container.resolve(BadgesListViewType.self) else {
            fatalError("BadgesListViewController has not registered a BadgesListViewType view")
        }
        badgesView.registerCollectionComponents()
        badgesView.delegate = self
        badgesView.toggleLoadingIndicator(value: true)
        self.view = badgesView
        badgesView.viewModel = nil
        title = "badges.title".localized
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        guard let vm = container.resolve(BadgesListViewModelType.self) else {
            fatalError("BadgesListViewController has not registered a BadgesListViewModelType viewModel")
        }
        self.viewModel = vm
        self.viewModel?.delegate = self
        reloadViewData()
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let view = self.view as? BadgesListViewType else {
            return
        }
        view.viewModel = viewModel
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let view = self.view as? BadgesListViewType else {
            return
        }
        view.reloadList()
        UserDefaults.standard.setValue(Date(), forKey: BadgesModule.kLastChangeDateKey)
    }
}

// MARK: ReloadableViewController

extension BadgesListViewController: ReloadableViewController {
    public func reloadViewData() {
        guard let viewModel = self.viewModel else {
            return
        }
        viewModel.loadData(purginCache: true) /*Change if requiered after server is done*/
    }
}

// MARK: BadgesListViewModelDelegate

extension BadgesListViewController: BadgesListViewModelDelegate {
    public func viewModelDidUpdate(viewModel: BadgesListViewModelType) {
        guard let view = self.view as? BadgesListViewType else {
            return
        }
        dismissErrorView(from: view.collectionView)
        view.viewModel = viewModel
        view.toggleLoadingIndicator(value: false)
    }

    public func viewModelDidFail(viewModel: BadgesListViewModelType, error: Error) {
        guard let view = self.view as? BadgesListViewType /*, let error = error as? NetworkError*/ else {
            return
        }
        let error = NetworkError.error(from: error as NSError)
        let style: MessageViewModel.MessageViewModelStyle = error == .noInternetConnection ? .noInternet : .error
        let messageViewModel = MessageViewModel.viewModel(with: style)
        presentErrorView(with: messageViewModel, in: view.collectionView)
        view.viewModel = viewModel
        view.toggleLoadingIndicator(value: false)
    }
}

// MARK: BadgesListDelegate

extension BadgesListViewController: BadgesListDelegate {
    public func listViewDidSelectBadge(with id: String) {
        let detailControllerNav = BadgeDetailViewController.embeededController(with: id)
        present(detailControllerNav, animated: true, completion: nil)
    }
}
