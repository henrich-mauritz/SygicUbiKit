import UIKit

// MARK: - ActivityStylingButton

public class ActivityStylingButton: StylingButton {
    private var maskLayer: CALayer?

    private lazy var animatableShape: CAShapeLayer = {
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = visualStyleProperties?.backgroundColor.cgColor
        shapeLayer.lineWidth = visualStyleProperties?.lineWidth ?? 2
        shapeLayer.strokeEnd = 0.9
        shapeLayer.opacity = 0.0
        return shapeLayer
    }()

    override public class func button(with style: StylingButton.ButtonStyle = .normal) -> ActivityStylingButton {
        let button = ActivityStylingButton(frame: CGRect(x: 0, y: 0, width: 0, height: style.height))
        button.buttonStyle = style
        return button
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        setupMaskLayer()
    }

    private func setupMaskLayer() {
        guard let visualProperties = self.visualStyleProperties else {
            return
        }
        maskLayer = CALayer()
        maskLayer?.backgroundColor = UIColor.black.cgColor
        maskLayer?.frame = layer.bounds
        maskLayer?.cornerRadius = visualStyleProperties?.radius ?? 0
        layer.mask = maskLayer
        animatableShape.frame = CGRect(x: bounds.width / 2 - visualProperties.height / 2, y: 0, width: visualProperties.height, height: visualProperties.height)
        let path = UIBezierPath(ovalIn: animatableShape.bounds)
        animatableShape.path = path.cgPath
        layer.addSublayer(animatableShape)
    }

    public func beginAnimating() {
        guard let maskLayer = self.maskLayer else { return }
        let finalRect = animatableShape.frame
        maskLayer.resizeAndMove(frame: finalRect,
                                animated: true,
                                duration: 0.3,
                                animationDelegate: self,
                                timingFunction: CAMediaTimingFunction(name: .easeOut))
        UIView.animate(withDuration: 0.1,
                       delay: 0.2,
                       options: .curveLinear,
                       animations: { [weak self] in
                        self?.backgroundColor = .clear
                        self?.titleLabel.alpha = 0.0
                        self?.animatableShape.opacity = 1.0
                       }, completion: nil)
    }

    public func endAnimating() {
        self.animatableShape.removeAllAnimations()
        let finalRect = layer.bounds
        maskLayer?.resizeAndMove(frame: finalRect,
                                 animated: true,
                                 duration: 0.3,
                                 animationDelegate: self,
                                 timingFunction: CAMediaTimingFunction(name: .easeOut))
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: .curveLinear,
                       animations: { [weak self] in
                        self?.backgroundColor = self?.visualStyleProperties?.backgroundColor
                        self?.titleLabel.alpha = 1.0
                        self?.animatableShape.opacity = 0
                       }, completion: nil)
    }
}

// MARK: CAAnimationDelegate

extension ActivityStylingButton: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            let shapeAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            shapeAnimation.toValue = Double.pi * 2
            shapeAnimation.duration = 1
            shapeAnimation.isCumulative = true
            shapeAnimation.repeatCount = Float.greatestFiniteMagnitude
            animatableShape.add(shapeAnimation, forKey: "rotation")
        }
    }
}
