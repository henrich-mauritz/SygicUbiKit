import Foundation
import UIKit
import CoreImage

public class RewardQRCodeStyleView: RewardDiscountCodeView {
    private let WIDTH_HEIGHT_QR: CGFloat = 244

    private lazy var qrCodeTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "rewards.code.qrSubtitle".localized
        label.textAlignment = .center
        label.textColor = .foregroundPrimary
        return label
    }()

    private lazy var qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: WIDTH_HEIGHT_QR).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: WIDTH_HEIGHT_QR).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Styling.cornerRadius
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private lazy var middleLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var middleLogoViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 70).isActive = true
        view.widthAnchor.constraint(equalToConstant: 70).isActive = true
        view.layer.cornerRadius = 35
        view.layer.masksToBounds = true
        view.backgroundColor = Styling.backgroundSecondary
        return view
    }()

    private lazy var qrViewContainer: UIView = {
        let view = UIView()
        return view
    }()

    override public func setupLayout() {
        super.setupLayout()
        qrViewContainer.addSubview(qrCodeImageView)
        qrViewContainer.addSubview(middleLogoViewContainer)
        middleLogoViewContainer.addSubview(middleLogoImageView)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(qrCodeImageView.topAnchor.constraint(equalTo: qrViewContainer.topAnchor))
        constraints.append(qrCodeImageView.bottomAnchor.constraint(equalTo: qrViewContainer.bottomAnchor))
        constraints.append(qrCodeImageView.centerXAnchor.constraint(equalTo: qrViewContainer.centerXAnchor))
        constraints.append(middleLogoImageView.centerXAnchor.constraint(equalTo: middleLogoViewContainer.centerXAnchor))
        constraints.append(middleLogoImageView.centerYAnchor.constraint(equalTo: middleLogoViewContainer.centerYAnchor))
        constraints.append(middleLogoViewContainer.centerXAnchor.constraint(equalTo: qrCodeImageView.centerXAnchor))
        constraints.append(middleLogoViewContainer.centerYAnchor.constraint(equalTo: qrCodeImageView.centerYAnchor))
        NSLayoutConstraint.activate(constraints)
        innerStackView.addArrangedSubview(qrCodeTextLabel)
        innerStackView.addArrangedSubview(qrViewContainer)
    }

    public func update(_ code: String?, validity: String?, middleImage: UIImage?) {
        super.update(code, validity: validity)
        guard let code = code else { return }
        qrCodeImageView.image = generateQRCode(from: code)
        if middleImage != nil {
            middleLogoImageView.image = middleImage
        } else {
            middleLogoViewContainer.isHidden = true
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            let scale = UIScreen.main.scale
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
            return UIImage(ciImage: output)
        }

        return nil
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let code = codeLabel.text else { return }
        qrCodeImageView.image = generateQRCode(from: code)
    }
}
