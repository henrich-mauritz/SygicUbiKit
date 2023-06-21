//
//  TrafficInfoDetail.swift
//  TrafficInfoSDK
//
//  Created by Juraj Antas on 28/04/2023.
//

import UIKit

class TrafficInfoDetailViewController: BaseViewController {
    var stackView: UIStackView!
    var viewModel: TrafficInfoData
    var onCloseBlock: (() -> Void)?
    var image: UIImage?
    var imageDetailButton: UIButton?
    
    required init(model: TrafficInfoData) {
        self.viewModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let radius = 20.0
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        stackView.layer.mask = mask
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .clear
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 18
        stackView.backgroundColor = .clear
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 0, bottom: 16, right: 0)
        stackView.backgroundColor = .backgroundPrimary
        view.addSubview(stackView)
        
        //Handle
        let handleView = UIView()
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.backgroundColor = .foregroundPrimary
        handleView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        handleView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        handleView.layer.cornerRadius = 2
        view.addSubview(handleView)
        
        let dismissView: UIView = UIView()
        dismissView.translatesAutoresizingMaskIntoConstraints = false
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        view.addSubview(dismissView)
        
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 6),
            handleView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            dismissView.topAnchor.constraint(equalTo: view.topAnchor),
            dismissView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dismissView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dismissView.bottomAnchor.constraint(equalTo: stackView.topAnchor)
        ])
        
        //From To header
        let title: String = viewModel.type.localizedString()
        
        //top part of detail icon + title and separator under it
        let titleLabel = UILabel.trConstructLabel(text: title, font: .stylingFont(.bold, with: 16), color: .foregroundPrimary, alignment: .left)
        
        let stackRow1 = UIStackView()
        stackRow1.translatesAutoresizingMaskIntoConstraints = false
        stackRow1.axis = .horizontal
        stackRow1.spacing = 12
        
        let image = TrafficInfoMapItem.imageViewForType(type: viewModel.type)
        image.setContentHuggingPriority(.required, for: .horizontal)
        image.setContentHuggingPriority(.required, for: .vertical)
        stackRow1.addArrangedSubview(image)
        stackRow1.addArrangedSubview(titleLabel)
        
        stackView.addArrangedSubview(stackRow1.embedInView(align: .center, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)))
        
        let separator = UIView.trCreateSeparatorView(color: .backgroundTertiary)
        stackView.addArrangedSubview(separator.embedInView(align: .center, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)))
        //---
        
        //description if exists
        if let description = viewModel.payload.description {
            let descriptionLabel = UILabel.trConstructLabel(text: description, font: UIFont.stylingFont(.regular, with: 16), color: .foregroundPrimary)
            descriptionLabel.numberOfLines = 0
            stackView.addArrangedSubview(descriptionLabel.embedInView(align: .left, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)), spacingAfter: 18)
        }
        
        if let url = viewModel.payload.uri {
            //image from camera, if exists
            let cameraImage = UIImageView()
            cameraImage.isUserInteractionEnabled = true
            cameraImage.clipsToBounds = true
            cameraImage.translatesAutoresizingMaskIntoConstraints = false
            cameraImage.contentMode = .scaleAspectFit
            cameraImage.setContentHuggingPriority(.required, for: .horizontal)
            //placeholder + activity
            cameraImage.image = UIImage(named: "whitePlaceholder", in: .module, compatibleWith: nil)!
            let activity = UIActivityIndicatorView(style: .medium)
            activity.hidesWhenStopped = true
            activity.translatesAutoresizingMaskIntoConstraints = false
            cameraImage.addSubview(activity)
            
            NSLayoutConstraint.activate([
                activity.centerXAnchor.constraint(equalTo: cameraImage.centerXAnchor),
                activity.centerYAnchor.constraint(equalTo: cameraImage.centerYAnchor)
            ])
            activity.startAnimating()
            
            //button on image
            let buttonImage = UIImage(named: "imageResizeButtonIcon", in: .module, compatibleWith: nil)!
            imageDetailButton = UIButton(type: .custom)
            guard let imageDetailButton = imageDetailButton else {return}
            
            imageDetailButton.isHidden = true
            imageDetailButton.setBackgroundImage(buttonImage, for: .normal)
            imageDetailButton.setBackgroundImage(buttonImage, for: .selected)
            imageDetailButton.translatesAutoresizingMaskIntoConstraints = false
            
            // imageDetailButton.addTarget(self, action: #selector(displayImageDetail), for: .touchUpInside)
            imageDetailButton.onTapped { [weak self] in
                print("display image detail")
                guard let self = self else {return}
                let vc = TrafficInfoImageDetailViewController(image: cameraImage.image ?? UIImage())
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
            
            cameraImage.addSubview(imageDetailButton)
            
            NSLayoutConstraint.activate([
                imageDetailButton.bottomAnchor.constraint(equalTo: cameraImage.bottomAnchor, constant: -16),
                imageDetailButton.trailingAnchor.constraint(equalTo: cameraImage.trailingAnchor, constant: -16)
            ])
            //-button
            
            cameraImage.downloaded(from: url, contentMode: .scaleAspectFit) { [weak self] in
                guard let self = self else {return}
                
                activity.stopAnimating()
                
                self.imageDetailButton?.isHidden = false
                
                self.image = cameraImage.image
            }
            stackView.addArrangedSubview(cameraImage, spacingAfter: 28)
        }
        
        //close button
        let closeButton = UIButton(type: .custom)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("trafficInfo.detail.close".localized.uppercased(), for: .normal)
        closeButton.titleLabel?.font = UIFont.stylingFont(.bold, with: 16)
        closeButton.setTitleColor(.foregroundSecondary, for: .normal)
        closeButton.backgroundColor = .backgroundSecondary
        closeButton.layer.cornerRadius = 16
        closeButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        closeButton.onTapped { [weak self] in
            guard let self = self else {return}
            
            self.onCloseAction()
        }
        
        stackView.addArrangedSubview(closeButton.embedInView(align: .natural, padding: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)))
    }
    
    override func swipeDownDissmisEnded() -> Bool {
        self.onCloseBlock?()
        return true
    }
    
    func onCloseAction() {
        
        self.dismiss(animated: true) {
            self.onCloseBlock?()
        }
    }
    
    //MARK: Handle Dismiss
    @objc func handleTap() {
        self.dismiss(animated: true) {
            self.onCloseBlock?()
        }
    }
    
}

