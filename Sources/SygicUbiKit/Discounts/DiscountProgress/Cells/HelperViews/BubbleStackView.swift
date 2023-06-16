import UIKit

class BubbleStackView: UIStackView {
    public var start: Bool = false {
        willSet {
            if newValue == true {
                firstBubble.isHidden = true
            }
        }
    }

    public var firstValue: String {
        set {
            firstBubble.label.text = newValue + " %"
        }

        get {
            return firstBubble.label.text ?? ""
        }
    }

    public var secondValue: String {
        set {
            secondBubble.label.text = newValue + " %"
        }

        get {
            return firstBubble.label.text ?? ""
        }
    }

    public var firstState: DiscountProgressType {
        set {
            firstBubble.state = newValue
        }

        get {
            return firstBubble.state
        }
    }

    public var secondState: DiscountProgressType {
        set {
            secondBubble.state = newValue
        }

        get {
            return secondBubble.state
        }
    }

    private let firstBubble: DiscountProgressIndicator = {
        let view = DiscountProgressIndicator()
        view.widthAnchor.constraint(equalToConstant: 44).isActive = true
        view.heightAnchor.constraint(equalToConstant: 28).isActive = true
        view.state = .missed
        return view
    }()

    let secondBubble: DiscountProgressIndicator = {
        let view = DiscountProgressIndicator()
        view.widthAnchor.constraint(equalToConstant: 44).isActive = true
        view.heightAnchor.constraint(equalToConstant: 28).isActive = true
        view.state = .canBeAchieved
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        alignment = .trailing
        spacing = 13
        distribution = .fillProportionally
        addArrangedSubview(firstBubble)
        addArrangedSubview(secondBubble)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func reset() {
        firstBubble.isHidden = false
        secondBubble.isHidden = false
        firstState = .missed
        secondState = .missed
        firstValue = ""
        secondValue = ""
    }
}
