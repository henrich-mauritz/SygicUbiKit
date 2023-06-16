import Foundation

// MARK: - NewsRepositoryType

public protocol NewsRepositoryType {
    func fetchDetail(with id: String, completion: @escaping ((Result<NewsDetail, NewsError>) -> ()))
    func dropCache()
}

// MARK: - NewsCacheRepositoryType

public protocol NewsCacheRepositoryType: NewsRepositoryType {
    func detail(with id: String) -> NewsDetail?
    func store(detail: NewsDetail)
}

// MARK: - NewsNetworkRepositoryType

public protocol NewsNetworkRepositoryType: NewsRepositoryType {}

extension NewsNetworkRepositoryType {
    func dropCache() {}
}

// MARK: - NewsRepository

public class NewsRepository: NewsRepositoryType {
    private let cacheRepo: NewsCacheRepositoryType
    private let networkRepo: NewsNetworkRepositoryType

    public init(cacheRepo: NewsCacheRepositoryType, networkRepo: NewsNetworkRepositoryType) {
        self.cacheRepo = cacheRepo
        self.networkRepo = networkRepo
    }

    public func fetchDetail(with id: String, completion: @escaping ((Result<NewsDetail, NewsError>) -> ())) {
        if let storedDetail = cacheRepo.detail(with: id) {
            completion(.success(storedDetail))
            return
        }

        networkRepo.fetchDetail(with: id) { result in
            switch result {
            case .failure(_):
                completion(.failure(NewsError.notFound))
            case let .success(detail):
                self.cacheRepo.store(detail: detail)
                completion(.success(detail))
            }
        }
    }

    public func dropCache() {
        cacheRepo.dropCache()
    }
}
