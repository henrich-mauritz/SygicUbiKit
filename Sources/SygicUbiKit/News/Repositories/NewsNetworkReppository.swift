import Foundation

class NewsNetworkRepository: NewsNetworkRepositoryType {
    private let netwokrManager = NetworkManager.shared

    func fetchDetail(with id: String, completion: @escaping ((Result<NewsDetail, NewsError>) -> ())) {
        netwokrManager.requestAPI(ApiRouterNews.newsDetail(id)) { (result: Result<NewsDetail, Error>) in
            switch result {
            case let .success(detail):
                completion(.success(detail))
            case .failure(_):
                completion(.failure(.notFound))
            }
        }
    }
}
