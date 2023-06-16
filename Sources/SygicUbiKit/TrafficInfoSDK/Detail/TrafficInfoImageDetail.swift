//
//  TrafficInfoImageDetail.swift
//  TrafficInfoSDK
//
//  Created by Juraj Antas on 03/05/2023.
//

import UIKit

class TrafficInfoImageDetailViewController: UIViewController, UIScrollViewDelegate {
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var closeButton: UIButton!
        
    var imageViewWidthConstraint: NSLayoutConstraint!
    var imageViewHeightConstraint: NSLayoutConstraint!
    
    var imageViewWidthFactor: CGFloat = 1.0
    var imageViewHeightFactor: CGFloat = 1.0
    
    var imgSize: CGSize = CGSize()
    var image: UIImage
    
    required init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        imgSize = image.size
        
        scrollView = UIScrollView()
        scrollView.contentMode = .scaleAspectFit
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        // init image view width constraint
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0.0)
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0.0)
        
        // to handle non-1:1 ratio images
        if imgSize.width > imgSize.height {
            imageViewHeightFactor = imgSize.height / imgSize.width
        } else {
            imageViewWidthFactor = imgSize.width / imgSize.height
        }
        
        let contentG = scrollView.contentLayoutGuide
    
        closeButton = UIButton(type: .custom)
        let closeButtonImage = UIImage(named: "closeButtonImageIcon", in: .module, compatibleWith: nil)!
        closeButton.setBackgroundImage(closeButtonImage, for: .normal)
        closeButton.setBackgroundImage(closeButtonImage, for: .selected)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.onTapped {
            self.dismiss(animated: true)
        }
        
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            
            imageView.topAnchor.constraint(equalTo: contentG.topAnchor, constant: 0.0),
            imageView.leadingAnchor.constraint(equalTo: contentG.leadingAnchor, constant: 0.0),
            imageView.trailingAnchor.constraint(equalTo: contentG.trailingAnchor, constant: 0.0),
            imageView.bottomAnchor.constraint(equalTo: contentG.bottomAnchor, constant: 0.0),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            imageViewWidthConstraint,
            imageViewHeightConstraint,
        ])
        
        imageView.image = image
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.maximumZoomScale = 10.0
        scrollView.minimumZoomScale = 0.5
        scrollView.backgroundColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let scale = view.frame.width / imgSize.width
        
        imageViewWidthConstraint.constant = imgSize.width * scale
        imageViewHeightConstraint.constant = imgSize.height * scale
        
        let f = view.frame
        scrollView.contentInset = .init(top: f.origin.y + f.height,
                                        left: f.origin.x + f.width,
                                        bottom: f.origin.y + f.height,
                                        right: f.origin.x + f.width)
    
        let aimSize = view.bounds.size
        var c = scrollView.contentOffset
        c.x -= (aimSize.width - imageViewWidthConstraint.constant) * 0.5
        c.y -= (aimSize.height - imageViewHeightConstraint.constant) * 0.5
        scrollView.contentOffset = c
        
    }
    
    //MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
