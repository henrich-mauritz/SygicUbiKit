import SceneKit
import UIKit

// MARK: - GradientDirection

enum GradientDirection {
    case Up
    case Left
    case UpLeft
    case UpRight
}

// MARK: - GradientMaterial

/// Material for the plane/trailing shape
class GradientMaterial: SCNMaterial {
    init(size: CGSize, color1: CIColor, color2: CIColor, direction: GradientDirection = .Up) {
        super.init()
        let image = GradientMaterial.imageGradient(size: size, color1: color1, color2: color2, direction: direction)
        diffuse.contents = image
        transparencyMode = .aOne
        transparency = 0.3
        transparencyMode = .default
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GradientMaterial {
    /// Creates an image with a specified color and makes it as a gradient transition
    /// - Parameters:
    ///   - size: the size. Make this size as close as possible in pixel size to the material shape
    ///   - color1: from color
    ///   - color2: to color
    ///   - direction: direction of the gradient
    /// - Returns: CGImage configured with a gradient drawing
    class func imageGradient(size: CGSize, color1: CIColor, color2: CIColor, direction: GradientDirection = .Up) -> CGImage? {
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CILinearGradient")
        var startVector: CIVector
        var endVector: CIVector

        filter!.setDefaults()

        switch direction {
            case .Up:
                startVector = CIVector(x: size.width * 0.5, y: 0)
                endVector = CIVector(x: size.width * 0.5, y: size.height)
            case .Left:
                startVector = CIVector(x: size.width, y: size.height * 0.5)
                endVector = CIVector(x: 0, y: size.height * 0.5)
            case .UpLeft:
                startVector = CIVector(x: size.width, y: 0)
                endVector = CIVector(x: 0, y: size.height)
            case .UpRight:
                startVector = CIVector(x: 0, y: 0)
                endVector = CIVector(x: size.width, y: size.height)
        }

        filter!.setValue(startVector, forKey: "inputPoint0")
        filter!.setValue(endVector, forKey: "inputPoint1")
        filter!.setValue(color1, forKey: "inputColor0")
        filter!.setValue(color2, forKey: "inputColor1")

        let image = context.createCGImage(filter!.outputImage!, from: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        return image
    }

    /// Based on input colors and percentage, creates a color with components modified by the percentage
    /// - Parameters:
    ///   - from: initial color
    ///   - to: end color
    ///   - percentage: the percentage to modifie the color compoentns
    /// - Returns: a final color based on the percentage value
    class func aniColor(from: UIColor, to: UIColor, percentage: CGFloat) -> UIColor {
        let fromComponents = from.cgColor.components!
        let toComponents = to.cgColor.components!

        let color = UIColor(red: fromComponents[0] + (toComponents[0] - fromComponents[0]) * percentage,
                            green: fromComponents[1] + (toComponents[1] - fromComponents[1]) * percentage,
                            blue: fromComponents[2] + (toComponents[2] - fromComponents[2]) * percentage,
                            alpha: fromComponents[3] + (toComponents[3] - fromComponents[3]) * percentage)
        return color
    }
}
