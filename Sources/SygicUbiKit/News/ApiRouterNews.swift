import Foundation

public enum ApiRouterNews: ApiEndpoints {
    case newsDetail(_ newsId: String)

    public var endpoint: String {
        switch self {
        case let .newsDetail(id):
            return "news/\(id)"
        }
    }
}
