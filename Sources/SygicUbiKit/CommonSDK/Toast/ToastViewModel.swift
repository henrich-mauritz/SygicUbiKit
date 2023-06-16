import Foundation
import UIKit

public struct ToastViewModel: ToastPresentable {
    public var title: String
    public var icon: UIImage?

    public init(title: String, icon: UIImage? = nil) {
        self.title = title
        self.icon = icon
    }
}
