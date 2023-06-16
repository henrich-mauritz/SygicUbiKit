import Foundation
import UIKit

// MARK: - PhotoEditViewController

class PhotoEditViewController: UIViewController {
    var sourceImage: UIImage! {
        didSet {
            workImage = resizedImage(sourceImage)
            redrawImage()
        }
    }

    var completionBlock: ((UIImage?) -> ())?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var workImage: UIImage!
    private let maskView: PhotoMask = PhotoMask()

    private var rotation: CGFloat = 0
    private var rotationGesture: CGFloat = 0
    private var zoom: CGFloat = 1

    private var zoomGesture: CGFloat = 0
    private var translationOffset: CGPoint = .zero
    private var translationOffsetGesture: CGPoint = .zero

    private let imageSize: CGSize = CGSize(width: 1024, height: 1024)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .actionPrimary
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelPressed(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed(_:)))

        let zoomRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.zoomGestureRecognized(_:)))
        zoomRecognizer.delegate = self
        zoomRecognizer.cancelsTouchesInView = false
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(self.rotationGestureRecognized(_:)))
        rotationRecognizer.delegate = self
        rotationRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(zoomRecognizer)
        view.addGestureRecognizer(rotationRecognizer)
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognized(_:))))

        view.cover(with: imageView)
        view.cover(with: maskView)
    }

    @objc
func panGestureRecognized(_ recognizer: UIPanGestureRecognizer) {
        let value = recognizer.translation(in: recognizer.view)
        switch recognizer.state {
        case .began:
            translationOffsetGesture = translationOffset
        case .changed:
            translationOffset.x = value.x + translationOffsetGesture.x
            translationOffset.y = value.y + translationOffsetGesture.y
            redrawImage()
        default:
            break
        }
    }

    @objc
func zoomGestureRecognized(_ recognizer: UIPinchGestureRecognizer) {
        let value = recognizer.scale - 1
        switch recognizer.state {
        case .began:
            zoomGesture = zoom
        case .changed:
            zoom = zoomGesture + value
            redrawImage()
        default:
            break
        }
    }

    @objc
func rotationGestureRecognized(_ recognizer: UIRotationGestureRecognizer) {
        let value = recognizer.rotation
        switch recognizer.state {
        case .began:
            rotationGesture = rotation
        case .changed:
            rotation = rotationGesture + value
            redrawImage()
        default:
            break
        }
    }

    func resizedImage(_ from: UIImage) -> UIImage {
        let originalSize = from.size

        let widthRatio = imageSize.width / originalSize.width
        let heightRatio = imageSize.height / originalSize.height

        var newSize: CGSize
        if widthRatio < heightRatio {
            newSize = CGSize(width: originalSize.width * heightRatio, height: originalSize.height * heightRatio)
        } else {
            newSize = CGSize(width: originalSize.width * widthRatio, height: originalSize.height * widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        from.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? from
    }

    func redrawImage() {
        guard let image = workImage else { return }
        let originalSize = image.size

        let widthRatio = imageSize.width / originalSize.width
        let heightRatio = imageSize.height / originalSize.height

        var newSize: CGSize
        if widthRatio < heightRatio {
            newSize = CGSize(width: originalSize.width * heightRatio, height: originalSize.height * heightRatio)
        } else {
            newSize = CGSize(width: originalSize.width * widthRatio, height: originalSize.height * widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: imageSize.width / 2 + translationOffset.x, y: imageSize.height / 2 + translationOffset.y)
        context?.scaleBy(x: zoom, y: zoom)
        context?.rotate(by: rotation)
        image.draw(in: CGRect(x: -imageSize.width / 2, y: -imageSize.width / 2, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        imageView.image = newImage
    }

    @objc
func donePressed(_ sender: UIBarButtonItem) {
        completionBlock?(imageView.image)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc
func cancelPressed(_ sender: UIBarButtonItem) {
        completionBlock?(nil)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: UIGestureRecognizerDelegate

extension PhotoEditViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - PhotoMask

class PhotoMask: UIView {
    let fillColor: UIColor = UIColor.black.withAlphaComponent(0.8)

    var circleRect: CGRect {
        let size = min(bounds.size.width, bounds.size.height)
        let offset = (max(bounds.size.width, bounds.size.height) - size) / 2.0
        var origin: CGPoint
        if bounds.size.width < bounds.size.height {
            origin = CGPoint(x: 0, y: offset)
        } else {
            origin = CGPoint(x: offset, y: 0)
        }
        return CGRect(x: origin.x, y: origin.y, width: size, height: size)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        fillColor.setFill()
        UIRectFill(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setBlendMode(.destinationOut)
        let path = UIBezierPath(ovalIn: circleRect)
        path.fill()

        context.setBlendMode(.normal)
    }
}
