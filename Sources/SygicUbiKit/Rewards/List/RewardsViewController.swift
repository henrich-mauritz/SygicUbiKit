import Swinject
import UIKit

// MARK: - RewardsViewController

public class RewardsViewController: UIViewController, InjectableType {
    public var hasNewContent: Bool { viewModel?.hasNewGainedReward ?? false }

    private var viewModel: RewardsListViewModelProtocol?

    public required init(with viewModel: RewardsListViewModelProtocol?) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func loadView() {
        guard let rewardsView = container.resolve(RewardsListViewProtocol.self) else {
            view = UIView()
            return
        }
        rewardsView.delegate = self
        view = rewardsView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "rewards.title".localized
        viewModel?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(forceReload), name: .forceReloadRewardsList, object: nil)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.reloadData(cleanCache: false)
        guard let filter = viewModel?.rewardsFilter else {
            AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticKeys.rewardShown, parameters: nil)
            return
        }
        if filter == .available {
            AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticKeys.rewardShown, parameters: nil)
        } else {
            AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticKeys.rewardGainedShown, parameters: nil)
        }
    }

    @objc
func forceReload() {
        viewModel?.reloadData(cleanCache: true)
        guard let view = self.view as? RewardsListViewProtocol else { return }
        view.selectSegment(at: 0)
    }
}

// MARK: ReloadableViewController

extension RewardsViewController: ReloadableViewController {
    public func reloadViewData() {
        viewModel?.reloadData(cleanCache: true)
    }
}

// MARK: RewardsViewModelDelegate

extension RewardsViewController: RewardsViewModelDelegate {
    public func viewModelUpdated(_ sender: Any) {
        guard let view = view as? RewardsListViewProtocol, let viewModel = viewModel else { return }
        view.update(with: viewModel)
        let gainedReward = UserDefaults.standard.bool(forKey: RewardsModule.UserDefaultKeys.awardedRewardKey)
        view.toggleSegmentControllRedDotAt(1, value: gainedReward)
        dismissErrorView(from: view.errorViewContainer)
    }

    public func viewModelDidFail(with error: Error) {
        guard let error = error as? RewardError, let view = view as? RewardsListViewProtocol else {
            return
        }
        view.update(with: viewModel)
        var messageViewModel: MessageViewModel
        if error == .unavailable { // "Comming soon" error
            messageViewModel = MessageViewModel(icon: nil, title: "rewards.commingSoon.title".localized, message: "rewards.commingSoon.description".localized)
        } else {
            let style: MessageViewModel.MessageViewModelStyle = error == .noInternetConnection ? .noInternet : .error
            messageViewModel = MessageViewModel.viewModel(with: style)
        }
        presentErrorView(with: messageViewModel, in: view.errorViewContainer)
    }
}

// MARK: RewardsListViewDelegate

extension RewardsViewController: RewardsListViewDelegate {
    public func rewardsListView(_ view: RewardsListViewProtocol, didSelect reward: RewardViewModelProtocol) {
        guard let detailController = container.resolve(RewardDetailViewController.self) else { return }
        detailController.viewModel = reward.detailViewModel(with: detailController)
        let navController = UINavigationController(rootViewController: detailController)
        navController.setupStyling()
        navController.modalPresentationStyle = .fullScreen
        navController.delegate = self
        present(navController, animated: true, completion: nil)
    }
}

// MARK: UINavigationControllerDelegate

extension RewardsViewController: UINavigationControllerDelegate {
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        .portrait
    }
}
