import UIKit

// MARK: - RewardDetailViewController

public class RewardDetailViewController: UIViewController, InjectableType {
    public var viewModel: RewardDetailViewModelProtocol? {
        didSet {
            viewModel?.delegate = self
        }
    }

    private lazy var closeButton: UIBarButtonItem = {
        UIBarButtonItem(title: "rewards.detail.closeButton".localized, style: .done, target: self, action: #selector(self.closeButtonPressed(_:)))
    }()

    override public func loadView() {
        view = container.resolve(RewardDetailViewProtocol.self)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let viewModel = self.viewModel else {
            return
        }
        if viewModel.rewardCode == nil {
            AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticKeys.rewardDetailShown, parameters: [AnalyticKeys.Parameters.rewardIdKey: "id\(viewModel.rewardId)"])
        } else {
            AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticKeys.rewardGainedDetailShown, parameters: [AnalyticKeys.Parameters.rewardIdKey: "id\(viewModel.rewardId)"])
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        if let navigationController = navigationController, navigationController.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = closeButton
        }
        guard let viewModel = viewModel, let view = view as? RewardDetailViewProtocol else { return }
        view.update(with: viewModel)
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    @objc private func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: RewardsViewModelDelegate

extension RewardDetailViewController: RewardsViewModelDelegate {
    public func viewModelUpdated(_ sender: Any) {
        guard let viewModel = viewModel, let view = view as? RewardDetailViewProtocol else { return }
        view.update(with: viewModel)
    }

    public func viewModelDidFail(with error: Error) {
        guard let view = view as? RewardDetailViewProtocol else { return }
        view.restoreUIAfterError(error: error)
        guard let error = error as? RewardDetailError else {
            return
        }

        if error == .claimFailed {
            let popUpController = StylingPopupViewController()
            let image = UIImage(named: "claimedRewardHandled", in: .module, compatibleWith: nil)
            let popupViewModel = StylingPopUpViewModel(title: "rewards.claimFailed.title".localized, subtitle: error.errorDescription ?? "",
                                                       actionTitle: "rewards.claimFailed.buttonTitle".localized, cancelTitle: nil, image: image)
            popupViewModel.setActionCallBack {
                popUpController.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.dismiss(animated: true, completion: nil)
                }
            }
            popUpController.configure(with: popupViewModel)
            self.present(popUpController, animated: true, completion: {
                NotificationCenter.default.post(name: .forceReloadRewardsList, object: nil)
            })
        }
    }
    
}
