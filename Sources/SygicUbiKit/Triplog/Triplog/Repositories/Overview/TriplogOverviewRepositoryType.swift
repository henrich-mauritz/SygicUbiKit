import Foundation

// MARK: - TriplogOverviewRepositoryType

public protocol TriplogOverviewRepositoryType {
    var data: TriplogOverviewDataType? { get }
    func fetch(overviewWith archiveId: String?, vehicleID: String?, _ completion: @escaping (Result<TriplogOverviewDataType, Error>) -> ())
    func cardOverviewModel(for data: TriplogOverviewCardDataType) -> TriplogOverviewCardDataType?
    func archivedData(with id: String) -> TriplogOverviewDataType?
    func purgueData()
}

extension TriplogOverviewRepositoryType {
    var data: TriplogOverviewDataType? {
        return nil
    }

    func cardOverviewModel(for data: TriplogOverviewCardDataType) -> TriplogOverviewCardDataType? {
        return nil
    }

    func archivedData(with id: String) -> TriplogOverviewDataType? {
        return nil
    }

    public func purgueData() {}
}

// MARK: - TriplogOverviewNetworkRepositoryType

public protocol TriplogOverviewNetworkRepositoryType: TriplogOverviewRepositoryType {}

// MARK: - TriplogOverviewCacheRepositoryType

public protocol TriplogOverviewCacheRepositoryType: AnyObject {
    var data: TriplogOverviewDataType? { get set }
    var archiveData: [String: TriplogOverviewDataType]? { get set }
    func cardOverviewModel(for data: TriplogOverviewCardDataType) -> TriplogOverviewCardDataType?
    func archivedData(with id: String) -> TriplogOverviewDataType?
    func purgueData()
}
