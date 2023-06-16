import UIKit

extension UIColor {
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }
}

extension UIColor {
    //TODO: delete DASHCAM COLORs redefinitions
    static let overlayColor = UIColor(76, 81, 102)
    static let textTitleWhite: UIColor = .foregroundDriving // = UIColor(230, 234, 242)
    static let textTitleBlack: UIColor = .buttonForegroundTertiaryActive
    static let textBodyBlack: UIColor = .buttonForegroundTertiaryActive
    static let textBodyWhite: UIColor = .foregroundDriving // = UIColor(157, 164, 179)
    static let blueLight: UIColor = .actionPrimary // = UIColor(0, 128, 255)
    static let blueDark: UIColor = .actionPrimary // = UIColor(54, 135, 217)
    static let blueIcon: UIColor = .actionPrimary // = UIColor(0, 64, 128)
    static let red2: UIColor = .negativePrimary // = UIColor(230, 57, 57)
    static let barLight: UIColor = .backgroundPrimary // = UIColor(242, 247, 255)
    static let barDark: UIColor = .backgroundPrimary // = UIColor(45, 51, 64)
}
