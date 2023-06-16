import Foundation
import UIKit
import Swinject

// MARK: - RewardToParticipatePopupController

public class RewardToParticipatePopupController: StylingPopupViewController {
    /// Check if any of passed contest has not been presented yet
    /// - Parameter contests: Contests IDs that are available for user
    /// - Returns: Contest id that has not been presented yet
    public static func shouldShowPopup(for contests: [String]) -> String? {
        guard let seenContests = UserDefaults.standard.array(forKey: RewardsPopupSeenUserDefaultsKey) as? [String] else {
            return contests.first
        }
        for contest in contests {
            if !seenContests.contains(contest) {
                return contest
            }
        }
        return nil
    }

    private static let RewardsPopupSeenUserDefaultsKey = "RewardsPopupSeenUserDefaultsKey"

    private lazy var attributedSubtitle: NSAttributedString = {
        let format = "rewards.participatePopup.subitle".localized
        let subtitle = String(format: format, contestTitle)
        let attrSubtitle = NSMutableAttributedString(string: subtitle)
        if let range = subtitle.range(of: contestTitle) {
            attrSubtitle.addAttributes([NSAttributedString.Key.font: UIFont.stylingFont(.bold, with: subtitleSize)], range: NSRange(range, in: subtitle))
        }
        return attrSubtitle
    }()

    private let contestId: String
    private let contestTitle: String

    public init(with contestId: String, contestTitle: String) {
        self.contestId = contestId
        self.contestTitle = contestTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        imageView.image = nil
        titleLabel.text = "rewards.participatePopup.title".localized
        subtitleLabel.attributedText = attributedSubtitle
        settingsButton.titleLabel.text = "rewards.participatePopup.primaryButton".localized
        cancelButton.titleLabel.text = "rewards.participatePopup.secondaryButton".localized
        super.viewDidLoad()
        settingsButton.addTarget(self, action: #selector(self.actionButtonPressed(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(self.cancelButtonPressed(_:)), for: .touchUpInside)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var seenContests = UserDefaults.standard.array(forKey: Self.RewardsPopupSeenUserDefaultsKey) as? [String] ?? []
        guard !seenContests.contains(contestId) else { return }
        seenContests.append(contestId)
        UserDefaults.standard.setValue(seenContests, forKey: Self.RewardsPopupSeenUserDefaultsKey)
    }

    @objc
private func actionButtonPressed(_ sender: Any) {
        guard let presenter = presentingViewController else { return }
        dismiss(animated: true) {
            self.presentRewardDetail(self.contestId, on: presenter)
        }
    }

    @objc
private func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: InjectableType

extension RewardToParticipatePopupController: InjectableType {
    private func presentRewardDetail(_ rewardId: String, on presenter: UIViewController) {
        var detailVC = container.resolve(RewardDetailViewController.self)
        if detailVC == nil {
            container.register(RewardDetailViewController.self) { _ -> RewardDetailViewController in
                RewardDetailViewController()
            }
            detailVC = container.resolve(RewardDetailViewController.self)
        }
        guard let detailController = detailVC else { return }
        detailController.viewModel = RewardDetailViewModel(with: rewardId)
        let navController = UINavigationController(rootViewController: detailController)
        navController.setupStyling()
        navController.modalPresentationStyle = .fullScreen
        presenter.present(navController, animated: true, completion: nil)
    }
}
