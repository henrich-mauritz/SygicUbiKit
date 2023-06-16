import Foundation

struct BadgeRepository: BadgesRepositoryType {
    let networkRepo: BadgesNetworkRepositoryType
    let cacheRepo: BadgesCacheRepositoryType

    func loadData(purginCache: Bool, completion: @escaping (Result<[BadgeItemType], Error>) -> ()) {
        networkRepo.loadData(purginCache: purginCache) { result in
            //Here check success or failure, if
            //sucess then cache otherwase
            //return error
            //for now just use same completion as we are mocking
            switch result {
            case let .success(items):
                for item in items {
                    //check for existance of keys in user defauls, if non existent means app is newly installed and set the values to current level
                    if UserDefaults.standard.value(forKey: "badge_\(item.id)_level") == nil {
                        UserDefaults.standard.setValue(item.currentLevel, forKey: "badge_\(item.id)_level")
                    }
                    UserDefaults.standard.synchronize()
                }
            default:
                print("do no more processing")
            }
            completion(result)
        }
    }

    func loadDetail(forBadgeWith id: String, completion: @escaping (Result<BadgeItemDetailType, Error>) -> ()) {
        networkRepo.loadDetail(forBadgeWith: id, completion: completion)
    }

    func checkForNewBadges(completion: @escaping (Result<NetworkWhatsNewBadgeData?, Error>) -> ()) {
        networkRepo.checkForNewBadges(completion: completion)
    }
}
