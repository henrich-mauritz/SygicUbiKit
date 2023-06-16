import Foundation
import UIKit

public class MessageViewModel: MessageViewModelType {
    public enum MessageViewModelStyle {
        case noInternet
        case error
        case custom(title: String, message: String, icon: UIImage)
    }

    /// Defautl images for the message view, in case of more, then there can be defined here if they wil lbe added inside the module

    public static var errorImage: UIImage { UIImage(named: "error", in: .module, compatibleWith: nil)! }
    public static var noConnectionImage: UIImage { UIImage(named: "offline", in: .module, compatibleWith: nil)! }

    public var image: UIImage?

    public var title: String

    public var message: String

    public class func viewModel(with style: MessageViewModelStyle) -> MessageViewModel {
        var vm: MessageViewModel
        switch style {
        case .noInternet:
            vm = MessageViewModel(icon: noConnectionImage, title: "common.noInternet.title".localized, message: "common.noInternet.description".localized)
        case .error:
            vm = MessageViewModel(icon: errorImage, title: "common.generalError.title".localized, message: "common.generalError.description".localized)
        case let .custom(title, message, icon):
            vm = MessageViewModel(icon: icon, title: title, message: message)
        }

        return vm
    }

    public init(icon: UIImage?, title: String, message: String) {
        self.image = icon
        self.title = title
        self.message = message
    }

    public init(imageName: String, title: String, message: String) {
        image = UIImage(named: imageName, in: .module, compatibleWith: nil)
        self.title = title
        self.message = message
    }
}
