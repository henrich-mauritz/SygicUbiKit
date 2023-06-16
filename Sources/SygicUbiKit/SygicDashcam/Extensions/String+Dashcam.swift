import CoreGraphics
import UIKit

extension String {
    var wordJoinerCharacter: Character {
        return "\u{a0}"
    }

    func insertJoinWordCharacterAfter(_ string: String) -> String {
        guard let numberRange: Range<String.Index> = self.range(of: "\(string)") else { return self }
        let index = self.distance(from: self.startIndex, to: numberRange.upperBound)
        var textChars = Array(self)
        textChars[index] = wordJoinerCharacter
        let stringWithWordJoiner = String(textChars)
        return stringWithWordJoiner
    }

    func image(attributes: [NSAttributedString.Key: Any], rect: CGRect) -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: rect.size)
            let img = renderer.image { _ in
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left

                self.draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            }

            return img
        } else {
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
            self.draw(in: rect, withAttributes: attributes)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return image!
        }
    }
}
