import Foundation
import UIKit

// MARK: - StylingPopUpViewModelDataType

public protocol StylingPopUpViewModelDataType {
    var image: UIImage? { get set }
    var title: String? { get set }
    var subtitle: String? { get set }
    var attributedSubtitle: NSAttributedString? { get set }
    var cancelButtonTitle: String? { get set }
    var actionButtonTitle: String? { get set }
    var cancelButonAction: (() -> ())? { get set }
    var actionButtonAction: (() -> ())? { get set }
}

public extension StylingPopUpViewModelDataType {
    var image: UIImage? {
        return UIImage(named: "permissionsPopup", in: .module, compatibleWith: nil)
    }
}

// MARK: - StylingPopUpViewModel

public class StylingPopUpViewModel: StylingPopUpViewModelDataType {
    public var actionButtonAction: (() -> ())?

    public var cancelButonAction: (() -> ())?

    public var actionButtonTitle: String?

    public var cancelButtonTitle: String?

    public var subtitle: String?

    public var attributedSubtitle: NSAttributedString?

    public var title: String?

    public var image: UIImage?

    public init(title: String?, subtitle: String, actionTitle: String? = nil, cancelTitle: String? = nil, image: UIImage? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.actionButtonTitle = actionTitle
        self.cancelButtonTitle = cancelTitle
        self.image = image
    }
    
    public init(title: String?, attributedSubtitle: NSAttributedString, actionTitle: String? = nil, cancelTitle: String? = nil, image: UIImage? = nil) {
        self.title = title
        self.attributedSubtitle = attributedSubtitle
        self.actionButtonTitle = actionTitle
        self.cancelButtonTitle = cancelTitle
        self.image = image
    }

    public func setActionCallBack(callBack: @escaping (() -> ())) {
        actionButtonAction = callBack
    }

    public func setcancelCallBack(callBack: @escaping (() -> ())) {
        cancelButonAction = callBack
    }
}
