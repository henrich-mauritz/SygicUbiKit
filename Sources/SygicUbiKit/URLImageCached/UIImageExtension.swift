import UIKit

public typealias ImageLoadingCompletion = (String, UIImage?, Error?) -> ()
public typealias ImageCompletionsArray = [ImageLoadingCompletion]

public extension UIImage {
    static func loadImage(from urlString: String, completion: @escaping ImageLoadingCompletion) {
        ImageLoader.shared.image(from: urlString, completion: completion)
    }
}
