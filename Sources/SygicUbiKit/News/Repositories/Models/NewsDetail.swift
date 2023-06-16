import Foundation

// MARK: - NewsDetail

public class NewsDetail: Codable {
   public struct Container: Codable {
        var type: NewsType
        var id: String
        var payload: NewsPayload
        var image: NewsImage?
    }

    public struct NewsPayload: Codable {
        var title: String
        var description: String
        var video: NewsVideoData?
    }

    public struct NewsVideoData: Codable {
        var videoType: String
        var videoPayload: VideoPayload

        public struct VideoPayload: Codable {
            var videoId: String
        }
    }

    public struct NewsImage: Codable {
        public var lightUri: String?
        public var darkUri: String?
    }

    var data: Container
}

public extension NewsDetail {
    var payload: NewsPayload { data.payload }
    var videoData: NewsVideoData? { payload.video }
}
