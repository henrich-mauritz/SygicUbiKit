import Foundation
import UIKit

class ActivityIndicatorView: UIView {
    enum IndicatorType {
        case small
        case medium
        case big
        case userDefined(width: CGFloat, height: CGFloat)
    }

    private let spiningView: UIImageView = {
        let spinImage = UIImage(named: "activitySpinner", in: .module, compatibleWith: nil)
        let spinImageIndicator: UIImageView = UIImageView(image: spinImage)

        return spinImageIndicator
    }()
}
