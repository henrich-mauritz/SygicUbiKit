import Foundation
import Swinject

// MARK: - NewsConfigurable

public protocol NewsConfigurable {
    var shouldLoadDetailWithSystemFont: Bool { get }
}

// MARK: - NewsModule

public class NewsModule {
    private static var defaultsInjected: Bool = false

    private init() {}

    public static func configure() {
        injectDefaults()
    }

    public static func injectDefaults() {
        guard !defaultsInjected else { return }
        let container = SYInjector.container
        //register components
        container.register(NewsRepositoryType.self) { _ -> NewsRepositoryType in
            let cacheRepo = NewsCacheRepository()
            let networkRepo = NewsNetworkRepository()
            return NewsRepository(cacheRepo: cacheRepo, networkRepo: networkRepo)
        }.inObjectScope(.container)

        container.register(NewsDetailViewModelType.self) { (_, idToLoad: String) -> NewsDetailViewModelType in
            NewsDetailViewModel(with: idToLoad)
        }

        container.register(NewsDetailViewController.self) { (_, viewModel: NewsDetailViewModelType) -> NewsDetailViewController in
            NewsDetailViewController(with: viewModel)
        }

        defaultsInjected = true
    }
}

// MARK: - NewsType

public enum NewsType: String, Codable {
    case video
    case text
}
