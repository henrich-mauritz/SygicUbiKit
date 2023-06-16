import Foundation
import UIKit

class BadgeDetailViewModel: BadgeViewModelDetailType, InjectableType {
    weak var delegate: BadgeDetailViewModelDelegate?
    var badgeId: String
    var badgeDetail: BadgeItemDetailType?
    var levelBackgroundColor: UIColor {
        if badgeDetail?.currentLevel == 0 {
            return .negativeSecondary
        }
        return .positivePrimary
    }

    var levelString: String {
        guard let detail = badgeDetail else {
            return ""
        }

        if detail.currentLevel == 0 {
            return "badges.detail.earnIt".localized
        } else {
            return String(format: "badges.detail.levelX".localized, detail.currentLevel)
        }
    }

    var imageLightUri: String {
        badgeDetail?.imageLightUri ?? ""
    }

    var imageDarkUri: String {
        badgeDetail?.imageDarkUri ?? imageLightUri
    }

    var currentProgress: CGFloat {
        guard let detail = badgeDetail, detail.progression.current != 0 else {
            return 0
        }
        return CGFloat((detail.progression.current * 100) / detail.progression.total) / 100.0
    }

    var progressString: String? {
        guard let detail = badgeDetail else {
            return nil
        }

        if detail.currentLevel == detail.maximumLevel {
            return nil
        }

        return String(format: "%i/%i", detail.progression.current, detail.progression.total)
    }

    var badgeBackgroundColor: UIColor {
        earned ? .badgeBackgroundEarned : .badgeBackgroundUnearned
    }

    private var earned: Bool {
        guard let detail = badgeDetail else {
            return false
        }
        return detail.currentLevel > 0
    }

    private lazy var repository: BadgesRepositoryType = container.resolveBadgesRepo()

    //MARK: - LifeCycle

    init(id: String) {
        self.badgeId = id
    }

    func loadDetail() {
        repository.loadDetail(forBadgeWith: self.badgeId) { [weak self] result in
            guard let `self` = self else {
                return
            }
            switch result {
            case let .success(detail):
                self.badgeDetail = detail
                self.delegate?.viewModelDidUpdate(viewModel: self)
            case let .failure(error):
                self.delegate?.viewModelDidFail(viewModel: self, error: error)
            }
        }
    }
}
