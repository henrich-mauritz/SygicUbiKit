import UIKit

// MARK: - ToastView

class ToastView: UIView {
    private var exitTimer: Timer?

    private let clippedView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundToast
        return view
    }()
    
    private let iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .foregroundToast
        return iconView
    }()

    private let label: UILabel = {
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 0
        textLabel.textColor = .foregroundToast
        textLabel.font = UIFont.stylingFont(with: 14)
        textLabel.textAlignment = .center
        return textLabel
    }()

    private var animatableConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)
        prepareDismissGesture()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        clippedView.apply(style: Styling.smallRoundedCornerStyle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {
        if let _ = iconView.image {
            clippedView.addSubview(iconView)
        }
        clippedView.addSubview(label)
        addSubview(clippedView)
        animatableConstraint = clippedView.centerYAnchor.constraint(equalTo: centerYAnchor)
        animatableConstraint?.constant = 200
        if let _ = iconView.image {
            iconView.topAnchor.constraint(equalTo: clippedView.topAnchor, constant: 5).isActive = true
            iconView.leadingAnchor.constraint(equalTo: clippedView.leadingAnchor, constant: 16).isActive = true
            iconView.trailingAnchor.constraint(equalTo: clippedView.trailingAnchor, constant: -16).isActive = true
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 5).isActive = true
        } else {
            label.topAnchor.constraint(equalTo: clippedView.topAnchor, constant: 5).isActive = true
        }
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: clippedView.leftAnchor, constant: 16),
            label.rightAnchor.constraint(equalTo: clippedView.rightAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: clippedView.bottomAnchor, constant: -5),
            clippedView.leftAnchor.constraint(equalTo: leftAnchor, constant: 75),
            clippedView.rightAnchor.constraint(equalTo: rightAnchor, constant: -75),
            animatableConstraint!,
            clippedView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
        ])
    }

    func update(viewModel: ToastPresentable) {
        label.text = viewModel.title.uppercased()
        iconView.image = viewModel.icon
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        clippedView.layoutIfNeeded()
        let clippedViewBounds = clippedView.bounds
        size.height = clippedViewBounds.height + 20
        return size
    }
}

//MARK: -  Animation

extension ToastView {
    func animateIn(completion: ((_ finished: Bool) -> Void)?) {
        guard let animatableConstraint = animatableConstraint else { return }

        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }

        animatableConstraint.constant = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0.2,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 6, options: [.curveEaseInOut], animations: {
                        self.layoutIfNeeded()
        }, completion: completion)

        timeOutExit()
    }

    func animateOut() {
        isUserInteractionEnabled = false
        guard let animatableConstraint = animatableConstraint else { return }
        animatableConstraint.constant = 100
        UIView.animate(withDuration: 0.2,
                       delay: 0.0, options: [.curveEaseInOut], animations: {
                        self.layoutIfNeeded()
        }, completion: nil)

        UIView.animate(withDuration: 0.2, delay: 0.2,
                       options: .curveEaseOut, animations: {
                        self.alpha = 0.0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    private func timeOutExit() {
        if let timer = exitTimer {
            timer.invalidate()
            exitTimer = nil
        }
        exitTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: {[weak self] timer in
            timer.invalidate()
            self?.exitTimer = nil
            self?.animateOut()
        })
    }
}

//MARK: -  Gestures

extension ToastView {
    private func prepareDismissGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissFromGesture(sender:)))
        swipeGesture.direction = .down
        addGestureRecognizer(swipeGesture)
    }

    @objc
private func dismissFromGesture(sender: Any) {
        if let timer = exitTimer {
            timer.invalidate()
            exitTimer = nil
        }
        animateOut()
    }
}
