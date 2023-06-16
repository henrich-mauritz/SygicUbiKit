import Foundation
import UIKit

public extension UIImageView {
    func calculateRectOfImageInImageView() -> CGRect {
            let imageViewSize = self.frame.size
            let imgSize = self.image?.size

            guard let imageSize = imgSize else {
                return CGRect.zero
            }

            let scaleWidth = imageViewSize.width / imageSize.width
            let scaleHeight = imageViewSize.height / imageSize.height
            let aspect = fmin(scaleWidth, scaleHeight)

            var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
            // Center image
            imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
            imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2

            // Add imageView offset
            imageRect.origin.x += self.frame.origin.x
            imageRect.origin.y += self.frame.origin.y

            return imageRect
        }
}

public extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }

        return scaledImage
    }
}
