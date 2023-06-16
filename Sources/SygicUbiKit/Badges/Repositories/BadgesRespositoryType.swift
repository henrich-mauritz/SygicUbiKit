import Foundation

// MARK: - BadgesRepositoryType

public protocol BadgesRepositoryType {
    func loadData(purginCache: Bool, completion: @escaping (Result<[BadgeItemType], Error>) -> ())
    func loadDetail(forBadgeWith id: String, completion: @escaping (Result<BadgeItemDetailType, Error>) -> ())
    func checkForNewBadges(completion: @escaping (Result<NetworkWhatsNewBadgeData?, Error>) -> ())
}

// MARK: - BadgesNetworkRepositoryType

public protocol BadgesNetworkRepositoryType: BadgesRepositoryType {}

// MARK: - BadgesCacheRepositoryType

public protocol BadgesCacheRepositoryType: BadgesRepositoryType {}
