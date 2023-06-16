import Foundation
import UIKit

public extension UIView {
    func cover(with view: UIView, insets: NSDirectionalEdgeInsets = .zero, toSafeArea: Bool = true) {
        if view.superview != self {
            addSubview(view)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        var toTopAnchor = safeAreaLayoutGuide.topAnchor
        var toBottomAnchor = safeAreaLayoutGuide.bottomAnchor
        if toSafeArea == false {
            toTopAnchor = topAnchor
            toBottomAnchor = bottomAnchor
        }
        var constraints = [view.topAnchor.constraint(equalTo: toTopAnchor, constant: insets.top)]
        constraints.append(view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.leading))
        constraints.append(view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.trailing))
        constraints.append(view.bottomAnchor.constraint(equalTo: toBottomAnchor, constant: -insets.bottom))
        NSLayoutConstraint.activate(constraints)
    }
    
    static func trCreateSeparatorView(color: UIColor) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return view
    }
    
    func addSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            self.addSubview(subview)
        }
    }
    
    func embedInView(align: NSTextAlignment, padding: UIEdgeInsets) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        view.addSubview(self)
        switch align {
        case .left:
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left),
                self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right)
            ])
        case .right:
            NSLayoutConstraint.activate([
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right),
                self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom)
            ])
        case .justified:
            fallthrough
        case .natural:
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left),
                self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right)
            ])
        case .center:
            let leading = self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left)
            leading.priority = .defaultLow
            let top = self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top)
            top.priority = .defaultLow
            let bottom = self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom)
            bottom.priority = .defaultLow
            let trailing = self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right)
            trailing.priority = .defaultLow
            NSLayoutConstraint.activate([
                leading,
                top,
                bottom,
                trailing,
                self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                self.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        default:
            //same as center
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left),
                self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right)
            ])
        }
        return view
    }
    
}

public extension UICollectionReusableView {
    class var headerIdentifier: String {
        return String(describing: self)
    }
    
}
