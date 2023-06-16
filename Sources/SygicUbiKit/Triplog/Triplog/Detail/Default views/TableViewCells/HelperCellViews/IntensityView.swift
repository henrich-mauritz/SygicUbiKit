import UIKit

class IntensityView: UIStackView {
    public var severnity: SevernityLevel = .zero {
        willSet {
            switch newValue {
            case .one:
                lowLevel.hide = false
                middleLevel.hide = true
                highLevel.hide = true
            case .two:
                lowLevel.hide = false
                middleLevel.hide = false
                highLevel.hide = true
            case .three:
                lowLevel.hide = false
                middleLevel.hide = false
                highLevel.hide = false
            default:
                lowLevel.hide = true
                middleLevel.hide = true
                highLevel.hide = true
            }
        }
    }

    private lazy var lowLevel: RoundedBoxView = {
        let colorView = RoundedBoxView()
        colorView.backgroundColor = SevernityLevel.one.toColor()
        return colorView
    }()

    private lazy var middleLevel: RoundedBoxView = {
        let colorView = RoundedBoxView()
        colorView.backgroundColor = SevernityLevel.two.toColor()
        return colorView
    }()

    private lazy var highLevel: RoundedBoxView = {
        let colorView = RoundedBoxView()
        colorView.backgroundColor = SevernityLevel.three.toColor()
        return colorView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        alignment = .center
        spacing = 3
        distribution = .fillProportionally
        addArrangedSubview(lowLevel)
        addArrangedSubview(middleLevel)
        addArrangedSubview(highLevel)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
