import Foundation
import UIKit
import Swinject

// MARK: - NewsDetailViewModelType

public protocol NewsDetailViewModelType {
    var detail: NewsDetail? { get set }
    var detailIdToLoad: String? { get set }
    var detailImageToLoad: NewsDetail.NewsImage? { get set }
    var currentSchemeImageUri: String? { get }
    var videoIdentifier: String? { get }
    var title: String? { get }
    var description: String? { get }
    var htmlDocumentText: NSAttributedString? { get }
    func loadDetail(with id: String, completion: @escaping ((_ success: Bool) -> ()))
    func refreshHtmlDocumentText(_ completion: @escaping () -> ())
}

// MARK: - NewsDetailViewModel

public class NewsDetailViewModel: NewsDetailViewModelType, InjectableType {
    public var detail: NewsDetail?

    public var detailIdToLoad: String?

    public var detailImageToLoad: NewsDetail.NewsImage?

    public var htmlDocumentText: NSAttributedString?

    private var textColor: UIColor { Styling.foregroundPrimary }

    public init(with detailToLoad: String) {
        self.detailIdToLoad = detailToLoad
    }

    public var currentSchemeImageUri: String? {
        if UITraitCollection.current.userInterfaceStyle == UIUserInterfaceStyle.dark {
            return detailImageToLoad?.darkUri ?? detailImageToLoad?.lightUri //for now get the detail image to load, later might change when propper API list is implemented
        }
        return detailImageToLoad?.lightUri
    }

    public var videoIdentifier: String? {
        return detail?.videoData?.videoPayload.videoId
    }

    public var title: String? {
        return detail?.data.payload.title
    }

    public var description: String? {
        return detail?.data.payload.description
    }

    private lazy var repository: NewsRepositoryType = {
        container.resolve(NewsRepositoryType.self)!
    }()

    public func loadDetail(with id: String, completion: @escaping ((_ success: Bool) -> ())) {
        repository.fetchDetail(with: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(detail):
                let tempImageData = self.detailImageToLoad
                self.detail = detail
                if detail.data.image == nil {
                    self.detail?.data.image = tempImageData
                }
                self.refreshHtmlDocumentText {
                    completion(true)
                }
            case .failure(_):
                completion(false)
            }
        }
    }

    public func refreshHtmlDocumentText(_ completion: @escaping () -> ()) {
        guard let description = self.description else { return }
        let htmlStyleString = String(format: htmlTemplate(), description.replacingOccurrences(of: "\n", with: "<br>"))
        guard let data = htmlStyleString.data(using: .utf8) else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                completion()
                return
            }

            do {
                let attributedString = try NSMutableAttributedString(data: data,
                                                                     options: [
                                                                         .documentType: NSAttributedString.DocumentType.html,
                                                                         .characterEncoding: String.Encoding.utf8.rawValue,
                                                                     ],
                                                                     documentAttributes: nil)
                //FIX for first time template might load wrong color
                //when device is on Light/Dark mode but application settings is in the opposite apperance
                let range = NSRange(location: 0, length: attributedString.string.count)
                attributedString.addAttribute(.foregroundColor, value: self.textColor, range: range)

                DispatchQueue.main.async {
                    self.htmlDocumentText = attributedString
                    completion()
                }
            } catch {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

    private func htmlTemplate() -> String {
        var fontFamily = "'\(UIFont.stylingFont(with: 1).familyName)'"
        if let newsConfigurable = container.resolve(NewsConfigurable.self), newsConfigurable.shouldLoadDetailWithSystemFont {
            fontFamily = "'-apple-system', 'HelveticaNeue'"
        }
        let htmlTemplate: String = """
            <!doctype html>
            <html>
              <head>
                <style>
                  body {
                    color: \(textColor.hexString!);
                    font-size: 16px;
                    font-family: \(fontFamily);
                  }
                </style>
              </head>
              <body>
                %@
              </body>
            </html>
            """
            return htmlTemplate
    }
}
