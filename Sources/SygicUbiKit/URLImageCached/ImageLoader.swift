import Foundation
import UIKit

class ImageLoader {
    static let shared = ImageLoader()

    typealias QueuedTask = (task: URLSessionTask, blocks: ImageCompletionsArray)

    var runningTasks = [QueuedTask]()
    let imageCache = NSCache<AnyObject, AnyObject>()

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60 * 5
        let session = URLSession(configuration: config)
        return session
    }()

    private init() {}

    func image(from urlString: String, completion: @escaping ImageLoadingCompletion) {
        guard let url = URL(string: urlString) else { return }
        // retrieves image if already available in cache
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            completion(urlString, imageFromCache, nil)
            return
        }

        // image does not available in cache.. so retrieving it from url...
        if let runningTask: (queued: QueuedTask, index: Int) = queuedTask(for: url) {
            addCompletionBlock(to: runningTask.index, completionToAdd: completion)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.completeTask(with: url, data: data, error: error)
            }
        }
        runningTasks.append((task, [completion]))
        task.resume()
    }

    private func queuedTask(for url: URL) -> (QueuedTask, Int)? {
        if let queued = runningTasks.enumerated().first(where: { _, element in
            element.0.originalRequest?.url == url
        }) {
            return (queued.element, queued.offset)
        }
        return nil
    }

    private func addCompletionBlock(to queuedIndex: Int, completionToAdd: @escaping ImageLoadingCompletion) {
        runningTasks[queuedIndex].blocks.append(completionToAdd)
    }

    private func completeTask(with url: URL, data: Data?, error: Error?) {
        guard let queuedTask = queuedTask(for: url) else { return }
        runningTasks.remove(at: queuedTask.1)

        guard error == nil else {
            for block in queuedTask.0.blocks {
                block(url.absoluteString, nil, error)
            }
            return
        }
        if let unwrappedData = data, let imageToCache = UIImage(data: unwrappedData) {
            imageCache.setObject(imageToCache, forKey: url.absoluteString as AnyObject)
            for block in queuedTask.0.blocks {
                block(url.absoluteString, imageToCache, nil)
            }
        }
    }
}
