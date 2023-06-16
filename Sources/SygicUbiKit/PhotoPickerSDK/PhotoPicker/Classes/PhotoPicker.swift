import UIKit

// MARK: - PhotoPicker

public class PhotoPicker: NSObject {
    private static let shared = PhotoPicker()

    private var edit: Bool = true
    private var completionBlock: ((UIImage?) -> ())?
    private weak var presentingViewController: UIViewController?

    override private init() {
        super.init()
    }

    public static func presentPhotoSelection(from presenting: UIViewController, edit: Bool = true, completion: @escaping (UIImage?) -> ()) {
        PhotoPicker.shared.presentingViewController = presenting
        PhotoPicker.shared.completionBlock = completion
        PhotoPicker.shared.edit = edit

        if UIImagePickerController.isSourceTypeAvailable(.camera) && UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let sheet = UIAlertController(title: "photoPicker.takePhotoOrChooseDescription".localized, message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "photoPicker.takePhotoDescription".localized, style: .default, handler: { _ in
                PhotoPicker.presentPicker(from: .camera, presentingController: presenting)
            }))
            sheet.addAction(UIAlertAction(title: "photoPicker.chooseFromPhotoDescription".localized, style: .default, handler: { _ in
                PhotoPicker.presentPicker(from: .photoLibrary, presentingController: presenting)
            }))
            sheet.addAction(UIAlertAction(title: "photoPicker.buttonTitle".localized, style: .cancel, handler: nil))
            presenting.present(sheet, animated: true, completion: nil)
        } else if UIImagePickerController.isSourceTypeAvailable(.camera) {
            PhotoPicker.presentPicker(from: .camera, presentingController: presenting)
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            PhotoPicker.presentPicker(from: .photoLibrary, presentingController: presenting)
        } else {
            completion(nil)
        }
    }

    private static func presentPicker(from source: UIImagePickerController.SourceType, presentingController: UIViewController) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = PhotoPicker.shared
        imagePicker.sourceType = source
        presentingController.present(imagePicker, animated: true, completion: nil)
        PhotoPicker.shared.presentingViewController = presentingController
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension PhotoPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completionBlock?(nil)
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image: UIImage = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        if edit {
            let editVC = PhotoEditViewController()
            editVC.sourceImage = image
            editVC.completionBlock = completionBlock
            let navigationController = UINavigationController(rootViewController: editVC)
            picker.dismiss(animated: true) {
                self.presentingViewController?.present(navigationController, animated: true, completion: nil)
            }
        } else {
            completionBlock?(image)
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
