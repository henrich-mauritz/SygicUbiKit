import UIKit

class DiscountProgressIndicator: UIView {
    public var state: DiscountProgressType = .missed {
        willSet {
            switch newValue {
            case .achieved:
                backgroundColor = .positivePrimary
            case .missed:
                backgroundColor = .backgroundSecondary
                label.text = "-"
            case .canBeAchieved:
                backgroundColor = .backgroundSecondary
            case .offSeason:
                backgroundColor = .clear
            }
        }
    }

    public let label: UILabel = {
        let label = UILabel()
        label.font = .stylingFont(.bold, with: 16)
        label.textColor = .foregroundPrimary
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        cover(with: label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2 //make it round it no matter the height
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
