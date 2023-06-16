//
//  BaseInformationViewController.swift
//  Triglav
//
//  Created by Henrich Mauritz on 08/12/2022.
//  Copyright © 2022 Sygic. All rights reserved.
//

import Foundation
import UIKit

open class BaseInformationViewController: UIViewController {
    public let imageView = UIImageView()
    public let fillerView = UIView()
    public let titleLabel = UILabel()
    
    public let mainStackView = UIStackView()
    public let contentStackView = UIStackView()
    public let buttonStack = UIStackView()
    public let subTitleStack = UIStackView()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
        setupStyle()
        setupConstraints()
    }
    
    private func setupContent() {
        view.addSubview(mainStackView)
        
        fillerView.addSubview(imageView)
        
        contentStackView.addArrangedSubview(fillerView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subTitleStack)
        contentStackView.addArrangedSubview(buttonStack)
        
        mainStackView.addArrangedSubview(fillerView)
        mainStackView.addArrangedSubview(contentStackView)
    }
    
    private func setupStyle() {
        view.backgroundColor = .backgroundPrimary
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .stylingFont(.light, with: 30)
        titleLabel.textColor = .foregroundPrimary
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.spacing = 30
        
        subTitleStack.axis = .vertical
        subTitleStack.distribution = .fill
        subTitleStack.spacing = 16
        
        buttonStack.axis = .vertical
        buttonStack.distribution = .equalSpacing
        buttonStack.spacing = 16
        
        mainStackView.axis = .vertical
        mainStackView.distribution = .fill
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        fillerView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: fillerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: fillerView.centerYAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
    
}
