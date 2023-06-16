//
//  BaseViewController.swift
//  CommonSDK
//
//  Created by Juraj Antas on 25/04/2023.
//

import UIKit

open class BaseViewController: UIViewController {
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinit of \(self)")
    }
    
    private lazy var activityIndicator: SYActivityIndicator = {
        return SYActivityIndicator()
    }()
    
    public func showActivityIndicator(blocking: Bool = false) {
        if blocking {
            activityIndicator.show(parentContainer: nil)
        } else {
            activityIndicator.show(parentContainer: self.view)
        }
    }
    
    public func hideActivityIndicator() {
        activityIndicator.hide()
    }
    
    @objc open func swipeDownDissmisEnded() -> Bool {
        //override in subclass
        return false
    }
}

class SYActivityIndicator: UIView {
    static let shared = SYActivityIndicator()
    private let radius: CGFloat = 30
    
    let container = UIView()
    let spinningView = UIView()
    var parentContainer : UIView? = nil
    var spinner: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.hidesWhenStopped = true
        return ai
    }()
    
    private convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
            
    private func setupViews(parentContainer: UIView?) {
        guard let window = parentContainer ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        window.addSubview(self)
        if parentContainer == nil {
            backgroundColor = .backgroundModal.withAlphaComponent(0.1)
        }
        
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 10
        container.backgroundColor = .clear
        
        spinningView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(container)
        container.addSubview(spinningView)
        spinningView.addSubview(spinner)
        spinner.startAnimating()
        
        NSLayoutConstraint.activate([
            spinningView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            spinningView.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: spinningView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: spinningView.centerYAnchor),
            
            container.topAnchor.constraint(equalTo: spinningView.topAnchor, constant: -46),
            container.bottomAnchor.constraint(equalTo: spinningView.bottomAnchor, constant: 46),
            container.leadingAnchor.constraint(equalTo: spinningView.leadingAnchor, constant: -62),
            container.trailingAnchor.constraint(equalTo: spinningView.trailingAnchor, constant: 62),
        ])
    }
    
    func show(parentContainer: UIView? = nil) {
        self.parentContainer = parentContainer
        setupViews(parentContainer: parentContainer)
        spinner.startAnimating()
    }
    
    func hide() {
        spinner.startAnimating()
        removeFromSuperview()
        parentContainer = nil
    }
    
}
