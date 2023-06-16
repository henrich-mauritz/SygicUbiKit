import Foundation

public protocol NewsInfoItemType: InfoItemType, Codable {
    var id: String { get set }
    var type: NewsType { get set }
    var image: NewsDetail.NewsImage? { get set }
}
