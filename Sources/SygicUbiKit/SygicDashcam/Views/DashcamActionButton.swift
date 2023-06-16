import UIKit

// MARK: - DashcamActionButton

public final class DashcamActionButton: UIButton {
    var iconSize: CGFloat = 26.0 {
        didSet {
            iconWidth.constant = iconSize
            iconHeight.constant = iconSize
        }
    }

    let buttonImageView = UIImageView()

    private let text: (title: String, loadingTitle: String)
    private let color: (textColor: UIColor, loadingColor: UIColor, backgroundColor: UIColor?)
    private let textLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView()

    private lazy var iconWidth: NSLayoutConstraint = {
        buttonImageView.widthAnchor.constraint(equalToConstant: iconSize)
    }()

    private lazy var iconHeight: NSLayoutConstraint = {
        buttonImageView.heightAnchor.constraint(equalToConstant: iconSize)
    }()

    override public func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(nil, for: state)

        textLabel.text = title
    }

    init(title: String = "",
         loadingTitle: String = "",
         textColor: UIColor = .buttonForegroundTertiaryPassive,
         loadingColor: UIColor = UIColor.buttonForegroundTertiaryActive.withAlphaComponent(0.5),
         backgroundColor: UIColor? = .buttonBackgroundTertiaryPassive,
         image: UIImage? = nil) {
        self.text = (title, loadingTitle)
        self.buttonImageView.image = image
        self.buttonImageView.tintColor = textColor
        self.color.textColor = textColor
        self.color.loadingColor = loadingColor
        self.color.backgroundColor = backgroundColor

        super.init(frame: .zero)

        setupUI()
    }

    override public var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? color.backgroundColor : color.backgroundColor?.withAlphaComponent(Styling.disabledStateAlpha)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.size.height / 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DashcamActionButton {
    func setUI(loading: Bool) {
        DispatchQueue.main.async {
            self.textLabel.text = loading ? self.text.loadingTitle : self.text.title
            self.textLabel.textColor = loading ? self.color.loadingColor : self.color.textColor
            self.buttonImageView.tintColor = self.textLabel.textColor
            self.buttonImageView.isHidden = self.buttonImageView.image == nil || loading
            loading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = !loading
        }
    }
}

// MARK: - Private

private extension DashcamActionButton {
    func setupUI() {
        backgroundColor = color.backgroundColor
        layer.masksToBounds = true

        addAutoLayoutSubviews(buttonImageView, textLabel, loadingIndicator)
        buttonImageView.constraints(centerX: centerXAnchor, centerY: centerYAnchor)
        textLabel.constraints(centerX: centerXAnchor, centerY: centerYAnchor)
        loadingIndicator.constraints(centerX: centerXAnchor, centerY: centerYAnchor)

        textLabel.textAlignment = .center
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.2
        textLabel.text = text.title
        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel.textColor = color.textColor

        buttonImageView.contentMode = .scaleAspectFit
        iconWidth.isActive = true
        iconHeight.isActive = true
    }
}
