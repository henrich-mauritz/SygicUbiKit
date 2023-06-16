import Foundation
import UIKit
import Swinject

// MARK: - TriplogModule

public class TriplogModule {
    private static var defaultsInjected: Bool = false

    private init() {}

    /// Injects default module components and returns module entry view controller.
    /// - Returns: Module entry view controller
    public static func rootViewController() -> TriplogOverviewViewController {
        injectDefaults()
        return SYInjector.container.resolve(TriplogOverviewViewController.self)!
    }

    /// Injects default components to InjectableType container required for module.
    /// Call this function before injecting your custom components for this module. No need to call, if you use TriplogModule.rootViewController() for initializing
    public static func injectDefaults() {
        guard !defaultsInjected else { return }
        let container = SYInjector.container
        container.injectTriplogRepositories()

        container.register(TriplogOverviewViewController.self, factory: { _ in TriplogOverviewViewController() })
        container.register(TriplogOverviewViewModelProtocol.self, factory: { _ in TriplogOverviewViewModel() })
        container.register(TriplogOverviewViewProtocol.self, factory: { _ in TriplogOverviewView() })
        container.register(TriplogOverviewCardViewModelProtocol.self, factory: { _ in TriplogOverviewCardViewModel() })
        container.register(TriplogOverviewMonthCardProtocol.self, factory: { _ in TriplogMonthCardView(frame: CGRect(x: 0, y: 0, width: 136, height: 260)) })
        container.register(TriplogMonthViewController.self, factory: { _ in TriplogMonthViewController() })

        container.register(TriplogCardViewModelProtocol.self, factory: {(_, model: TriplogOverviewCardDataType) in
            TriplogMonthViewModel(withCardModel: model)
        })

        container.register(TriplogOverviewViewModelProtocol.self, name: TriplogResolversNames.archiveResolver) { (_, kilometers: Double, cards: [TriplogOverviewCardViewModelProtocol]) -> TriplogOverviewViewModelProtocol in
            TriplogArchiveViewModel(with: kilometers, cards: cards)
        }

        container.register(TriplogArchivePeriodOverViewModel.self.self, factory: { (_, id: String, percentage: Int, distance: Double, start: Date, end: Date) in
            TriplogArchivePeriodOverViewModel(withArchivedId: id,
                                              discountPercentage: percentage,
                                              distance: distance,
                                              start: start,
                                              end: end)
        })
        container.register(TriplogMonthViewProtocol.self, factory: { _ in TriplogMonthView() })
        container.register(TriplogTripCardViewModelProtocol.self, factory: { _ in TriplogTripCardViewModel() })
        container.register(TriplogMapViewProtocol.self, factory: { _ in TriplogMapView() })
        container.register(TripDetailViewModelProtocol.self, factory: { _ in TripDetailViewModel() })
        container.register(TripDetailViewProtocol.self, factory: { _ in TripDetailView() })
        container.register(TripDetailViewController.self, factory: { _ in TripDetailViewController() })

        container.register(TripDetailPartialScoreViewModelProtocol.self) { (_: Resolver, model: TripDetailPartialScoreModelProtocol) -> TripDetailPartialScoreViewModelProtocol in
            TripDetailSelectionViewModel(with: model)
        }
        container.register(TripDetailPartialScoreViewProtocol.self, factory: { _ in TripDetailPartialScoreView() })
        container.register(TripDetailPartialScoreViewController.self, factory: { _ in TripDetailPartialScoreViewController() })

        container.register(TriplogEventDetailViewModelProtocol.self, factory: { [weak container] (_: Resolver, model: TriplogEventDetailModelProtocol) -> TriplogEventDetailViewModelProtocol in
            let viewModel = TriplogEventDetailViewModel(model: model)
            viewModel.container = container
            return viewModel
        })
        container.register(TriplogEventDetailViewProtocol.self, factory: { _ in TriplogEventDetailView() })
        container.register(TriplogEventDetailViewController.self, factory: { _ in TriplogEventDetailViewController() })

        container.register(TripDetailReportViewModelProtocol.self, factory: { _ in TripDetailReportViewModel() })
        container.register(TripDetailReportViewProtocol.self, factory: { _ in TripDetailReportView() })
        container.register(TripDetailReportViewControllerProtocol.self, factory: { [unowned container] _ in
            let controller = TripDetailReportViewController()
            controller.container = container
            return controller
        })

        container.register(TripDetailAddressCellProtocol.self, factory: { _ in TripAddressCell() })
        container.register(TripDetailCellProtocol.self, factory: { _ in TriplogBasicTableViewCell() })
        container.register(TripCongratulationsViewCellProtocol.self, factory: { _ in CongratulationsViewCell() })
        container.register(TripDetailEventCellProtocol.self, factory: { _ in TriplogBasicTableViewCell() })
        container.register(TripDetailPartialScoreEventCellProtocol.self, factory: { _ in DetailSelectionCell() })
        container.register(TripDetailScoreCellProtocol.self, factory: { _ in DisclosureTableViewCell() })
        container.register(TriplogMapViewController.self, factory: { _ in TriplogMapViewController() })
        container.register(TriplogReportMapViewController.self, factory: { _ in TriplogReportMapViewController() })
        container.register(TripDetailScoreViewController.self, factory: { _ in TripDetailScoreViewController() })

        defaultsInjected = true
    }
}

// MARK: - TriplogResolversNames

public struct TriplogResolversNames {
     static let archiveResolver: String = "TriplogArchiveReslover"
}

public extension Notification.Name {
    static var newTripScoreNotification: Notification.Name { Notification.Name("newTripNotification") }
}
