import UIKit

class SliderButtonView: UIView {
    enum ButtomPosition {
        case stop, start
    }

    public let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .buttonForegroundPrimary
        label.textAlignment = .center
        label.font = UIFont.stylingFont(.bold, with: 20)
        label.text = "driving.slideButtonStart".localized.uppercased()
        return label
    }()

    public var startBlock: (() -> Void)?
    public var stopBlock: (() -> Void)?
    public var stopString: String = "driving.slideButtonStop".localized.uppercased()
    public var startString: String = "driving.slideButtonStart".localized.uppercased()
    private let bottomMargin: CGFloat = 11.0
    private let height: CGFloat = 24.0

    public var buttonPosition: ButtomPosition = .start {
        didSet {
            guard oldValue != buttonPosition else { return }
            var endText: String = ""
            if buttonPosition == .stop {
                startBlock?()
                endText = stopString
            } else {
                stopBlock?()
                endText = startString
            }
            UIView.animate(withDuration: 0.2,
                           delay: 0.0,
                           options: [.curveEaseOut, .beginFromCurrentState]) {
                self.label.text = endText
            } completion: { _ in
                //finished.. do somehting fancy here maybe?
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        initSetup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSetup() {
        backgroundColor = .buttonBackgroundPrimary
        layer.cornerRadius = Styling.driveSliderButtonCorenerRadius
        initLabelView()
    }

    private func initLabelView() {
        addSubview(label)
        setupConstriantsForLabel()
    }

    private func setupConstriantsForLabel() {
        let leadingConstraint = label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0)
        let trailingConstraint = label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        let centerY = label.centerYAnchor.constraint(equalTo: centerYAnchor)
        let heightConstraint = label.heightAnchor.constraint(equalToConstant: height)
        let constraints = [ leadingConstraint, trailingConstraint, centerY, heightConstraint ]
        NSLayoutConstraint.activate(constraints)
    }
}
