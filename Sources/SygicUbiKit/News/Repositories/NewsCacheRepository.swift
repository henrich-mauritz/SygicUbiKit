import Foundation

class NewsCacheRepository: NewsCacheRepositoryType {
    private lazy var cache: NSCache<NSString, NewsDetail> = {
        let newsCache = NSCache<NSString, NewsDetail>()
        return newsCache
    }()

    func fetchDetail(with id: String, completion: @escaping ((Result<NewsDetail, NewsError>) -> ())) {
        if let cachedDetail = cache.object(forKey: id as NSString) {
            completion(.success(cachedDetail))
        } else {
            completion(.failure(.notFound))
        }
    }

    func detail(with id: String) -> NewsDetail? {
        return cache.object(forKey: id as NSString)
    }

    func store(detail: NewsDetail) {
        cache.setObject(detail, forKey: detail.data.id as NSString)
    }

    func dropCache() {
        //print("before removal \(cache) \n\n")
        cache.removeAllObjects()
//        print("after removal \(cache)")
    }
}
