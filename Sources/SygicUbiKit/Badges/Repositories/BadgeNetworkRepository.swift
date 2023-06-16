import Foundation

class BadgeNetworkRepository: BadgesNetworkRepositoryType {
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.loggoutNotification), name: .userLoggedOut, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func loadData(purginCache: Bool, completion: @escaping (Result<[BadgeItemType], Error>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterBadges.badgeList) { (result: Result<NetworkBadgesList, Error>) in
            switch result {
            case let .success(data):
                completion(.success(data.badges))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func loadDetail(forBadgeWith id: String, completion: @escaping (Result<BadgeItemDetailType, Error>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterBadges.badgeDetail(id)) { (result: Result<NetworkBadgeData, Error>) in
            switch result {
            case let .success(data):
                completion(.success(data.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func checkForNewBadges(completion: @escaping (Result<NetworkWhatsNewBadgeData?, Error>) -> ()) {
        let lastDate = UserDefaults.standard.value(forKey: BadgesModule.kLastChangeDateKey) as? Date ?? Date()
        NetworkManager.shared.requestAPI(ApiRouterBadges.whatsNew(lastDate)) { (result: Result<NetworkWhatsNewBadgeData?, Error>) in
            completion(result)
        }
    }

    @objc
private func loggoutNotification() {
        UserDefaults.standard.setValue(nil, forKey: BadgesModule.kLastChangeDateKey)
    }
}
