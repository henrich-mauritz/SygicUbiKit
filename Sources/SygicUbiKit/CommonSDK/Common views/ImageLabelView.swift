//
//  ImageLabelView.swift
//  Common
//
//  Created by Henrich Mauritz on 08/12/2022.
//

import Foundation
import UIKit

open class ImageLabelView: UIView {
    private let imageView: UIImageView
    private let label = UILabel()
    
    public init(image: UIImage, text: String) {
        imageView = UIImageView(image: image)
        label.text = text
        super.init(frame: .zero)
        setupContent()
        setupStyle()
        setupConstraints()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContent() {
        addSubview(imageView)
        addSubview(label)
    }
    
    private func setupStyle() {
        label.textAlignment = .left
        label.font = .stylingFont(with: 14)
        label.textColor = .foregroundPrimary
        label.numberOfLines = 0
        
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
