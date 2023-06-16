import UIKit

// MARK: - Shadows

extension UIView {
    func addDropShadow() {
        addDropShadow(radius: 4)
    }

    func addDropShadow(radius: CGFloat) {
        layer.shadowColor = UIColor.textTitleBlack.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
    }

    /// Adds default shadow as transparent border from bottom and right side
    func addBorderShadow() {
        layer.shadowColor = UIColor.textTitleBlack.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 0.0
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
    }
}

extension UIView {
    class var className: String {
        guard let parsedName = NSStringFromClass(self).components(separatedBy: ".").last
            else {
                assertionFailure()
                return ""
        }

        return parsedName
    }
}

// MARK: - Safeareas

extension UIView {
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }

    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }

    var safeAreaLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leadingAnchor
        } else {
            return self.leadingAnchor
        }
    }

    var safeAreaTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.trailingAnchor
        } else {
            return self.trailingAnchor
        }
    }
}

extension UIView {
    func addAutoLayoutSubviews(_ views: UIView...) {
        views.compactMap {$0}.forEach(addAutoLayoutSubview)
    }

    func addAutoLayoutSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
}

// MARK: - Blur

@objc
extension UIView {
    @discardableResult
    func addBlur(style: UIBlurEffect.Style = .dark) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurBackground = UIVisualEffectView(effect: blurEffect)
        blurBackground.isUserInteractionEnabled = false
        insertSubview(blurBackground, at: 0)
        blurBackground.layer.cornerRadius = layer.cornerRadius
        blurBackground.clipsToBounds = true
        blurBackground.translatesAutoresizingMaskIntoConstraints = false
        blurBackground.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blurBackground.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurBackground.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blurBackground.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        return blurBackground
    }
}

extension UIView {
    /// attaches all sides of the receiver to its parent view
    func coverWholeSuperview(margin: CGFloat = 0.0) {
        let view = superview
        layoutAttachTop(to: view, margin: margin)
        layoutAttachBottom(to: view, margin: margin)
        layoutAttachLeading(to: view, margin: margin)
        layoutAttachTrailing(to: view, margin: margin)
    }

    /// attaches the top of the current view to the given view's top if it's a superview of the current view
    /// or to it's bottom if it's not (assuming this is then a sibling view).
    @discardableResult
    func layoutAttachTop(to: UIView? = nil, margin: CGFloat = 0.0) -> NSLayoutConstraint {
        let view: UIView? = to ?? superview
        let isSuperview = view == superview
        let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .top : .bottom, multiplier: 1.0,
                                            constant: margin)
        superview?.addConstraint(constraint)

        return constraint
    }

    /// attaches the bottom of the current view to the given view
    @discardableResult
    func layoutAttachBottom(to: UIView? = nil, margin: CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .bottom : .top, multiplier: 1.0,
                                            constant: -margin)
        if let priority = priority {
            constraint.priority = priority
        }
        superview?.addConstraint(constraint)

        return constraint
    }

    /// attaches the leading edge of the current view to the given view
    @discardableResult
    func layoutAttachLeading(to: UIView? = nil, margin: CGFloat = 0.0) -> NSLayoutConstraint {
        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .leading : .trailing, multiplier: 1.0,
                                            constant: margin)
        superview?.addConstraint(constraint)

        return constraint
    }

    /// attaches the trailing edge of the current view to the given view
    @discardableResult
    func layoutAttachTrailing(to: UIView? = nil, margin: CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .trailing : .leading, multiplier: 1.0,
                                            constant: -margin)
        if let priority = priority {
            constraint.priority = priority
        }
        superview?.addConstraint(constraint)

        return constraint
    }

    // for anchoring View
    struct AnchoredConstraints {
        var top, leading, bottom, trailing, width, height, centerX, centerY: NSLayoutConstraint?
    }

    @discardableResult
    func constraints(top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil,
                     trailing: NSLayoutXAxisAnchor? = nil, padding: UIEdgeInsets = .zero, size: CGSize = .zero,
                     centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil,
                     centerXOffset: CGFloat = 0, centerYOffset: CGFloat = 0) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()

        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }

        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }

        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }

        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }

        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }

        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }

        if let centerX = centerX {
            anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: centerX, constant: centerXOffset)
        }

        if let centerY = centerY {
            anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: centerY, constant: centerYOffset)
        }

        [
            anchoredConstraints.top,
            anchoredConstraints.leading,
            anchoredConstraints.bottom,
            anchoredConstraints.trailing,
            anchoredConstraints.width,
            anchoredConstraints.height,
            anchoredConstraints.centerX,
            anchoredConstraints.centerY,
        ].forEach { $0?.isActive = true }

        return anchoredConstraints
    }

    func topConstraint() -> NSLayoutConstraint? {
        let predicate1 = NSPredicate(format: "firstAttribute = %d AND firstItem = %@", NSLayoutConstraint.Attribute.top.rawValue, self)
        let predicate2 = NSPredicate(format: "secondAttribute = %d AND secondItem = %@", NSLayoutConstraint.Attribute.top.rawValue, self)
        let finalPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
        let topConstraints: [NSLayoutConstraint]? = (superview?.constraints as NSArray?)?.filtered(using: finalPredicate) as? [NSLayoutConstraint]

        return topConstraints?.first
    }
}
