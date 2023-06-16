import Foundation

class BadgeCacheRepository: BadgesCacheRepositoryType {
    func loadData(purginCache: Bool, completion: @escaping (Result<[BadgeItemType], Error>) -> ()) {}
    func loadDetail(forBadgeWith id: String, completion: @escaping (Result<BadgeItemDetailType, Error>) -> ()) {}
    func checkForNewBadges(completion: @escaping (Result<NetworkWhatsNewBadgeData?, Error>) -> ()) {}
}
