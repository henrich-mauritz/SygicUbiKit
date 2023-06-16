//
//  CoverFromBottomPresentationController.swift
//  CommonSDK
//
//  Created by Juraj Antas on 05/08/2022.
//

import UIKit

public class CoverFromBottomPresentationController: UIPresentationController {
    private lazy var dimmingView: UIView! = {
        guard let container = containerView else { return nil }
        let view = UIView(frame: container.bounds)
        view.backgroundColor = .backgroundOverlay.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        //dismiss view using swipe
        presentedView!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        //dismiss view using tap to grey area
        presentedView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
      
    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        return CGRect(x: 0, y: 0, width: container.bounds.width, height: container.bounds.height)
    }
    
     var frameOfDimmingView: CGRect {
         // dimming view has to be taller, so animation wont be visible
         let offset: CGFloat = 1300
        guard let container = containerView else { return .zero }
        return CGRect(x: 0, y: -offset, width: container.bounds.width, height: container.bounds.height + offset)
    }
    
    public override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        dimmingView.frame = frameOfDimmingView
    }
    
    public override func presentationTransitionWillBegin() {
        guard let container = containerView,
              let coordinator = presentingViewController.transitionCoordinator else { return }
        
        dimmingView.alpha = 0
        dimmingView.isUserInteractionEnabled = true
        dimmingView.onTapped { [weak self] in
            self?.presentedViewController.dismiss(animated: true, completion: nil)
        }
        container.addSubview(dimmingView)
        dimmingView.addSubview(presentedViewController.view)

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: container.topAnchor, constant: 0)
        ])

        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else { return }
            
            self.dimmingView.alpha = 1
        }, completion: nil)
    }
    
    public override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else { return }
            
            self.dimmingView.alpha = 0
        }, completion: nil)
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            let key = "swipeDownDissmisEnded" //DONT TRANSLATE!
            if presentedViewController.responds(to: NSSelectorFromString(key)) {
                _ = presentedViewController.value(forKey: key)
            }
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        let visibleViewHeight = presentedViewController.view.subviews.first?.frame.height ?? 400
        
        let viewTranslation = sender.translation(in: containerView)
        let maxPanDistance: CGFloat = visibleViewHeight / 2
        switch sender.state {
        case .changed:
            if viewTranslation.y < 0 { return }
            let percentage = viewTranslation.y / maxPanDistance
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.containerView?.transform = CGAffineTransform(translationX: 0, y: viewTranslation.y)
                self.dimmingView.alpha = 1 - percentage
            })
            
        case .ended:
            if viewTranslation.y < maxPanDistance {
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 1,
                               options: .curveEaseOut,
                               animations: {
                    self.containerView?.transform = .identity
                    self.dimmingView.alpha = 1
                })
            } else {
                presentedViewController.dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
}

extension CoverFromBottomPresentationController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        self
    }
    
}
