import UIKit

// MARK: - SygicSegmentedControl

public class SygicSegmentedControl: UIControl {
    public var height: CGFloat = 28 {
        didSet {
            heightConstraint.constant = height
        }
    }

    public var selectedSegmentIndex: Int = 0 {
        didSet {
            sendActions(for: .valueChanged)
        }
    }

    public var cornerRadius: CGFloat = Styling.segmentedControlCornerRadius {
        didSet {
            updateCornerRadius()
        }
    }

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private var segments = [SygicSegmentedControlItem]()

    private lazy var slider: UIView = {
        let slider = UIView()
        slider.backgroundColor = .buttonBackgroundPrimary
        return slider
    }()

    private lazy var heightConstraint: NSLayoutConstraint = {
        heightAnchor.constraint(equalToConstant: height)
    }()

    private var sliderWidthConstraint: NSLayoutConstraint?

    private var sliderLeadingConstraint: NSLayoutConstraint?

    private let animationDuration: TimeInterval = 0.2

    public required init(items: [Any]?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
        setupLayout()
        updateSegementedControl(with: items)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func updateSegementedControl(with items: [Any]?) {
        if let strings = items as? [String] {
            update(with: strings.segments())
        } else if let controls = items as? [SygicSegmentedControlItem] {
            update(with: controls)
        } else {
            // TODO: segments with icons
        }
    }

    public func showNotificationBadge(at: Int, show: Bool = true) {
        guard segments.count > at else { return }
        segments[at].showNotificationBadge = show
    }

    private func setupLayout() {
        backgroundColor = .backgroundSecondary
        updateCornerRadius()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.addSubview(slider)
        var constraints = [NSLayoutConstraint]()
        constraints.append(stackView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(stackView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(stackView.topAnchor.constraint(equalTo: slider.topAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: slider.bottomAnchor))
        constraints.append(heightConstraint)
        NSLayoutConstraint.activate(constraints)
    }

    private func updateCornerRadius() {
        layer.cornerRadius = cornerRadius
        slider.layer.cornerRadius = cornerRadius
    }

    private func update(with items: [SygicSegmentedControlItem]) {
        for segment in segments {
            stackView.removeArrangedSubview(segment)
            segment.removeFromSuperview()
        }
        segments.removeAll()
        sliderWidthConstraint?.isActive = false
        sliderLeadingConstraint?.isActive = false
        segments.append(contentsOf: items)
        for newSegment in segments {
            stackView.addArrangedSubview(newSegment)
            newSegment.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
        }
        if let segment = segments.first {
            sliderWidthConstraint = slider.widthAnchor.constraint(equalTo: segment.widthAnchor, multiplier: 1)
            sliderWidthConstraint?.isActive = true
            selectSegment(segment, at: 0, animated: false)
        }
    }

    private func selectSegment(_ segment: SygicSegmentedControlItem, at index: Int, animated: Bool = true) {
        guard segments.first(where: { $0 == segment }) != nil,
            segment.superview == slider.superview else { return }
        sliderLeadingConstraint?.isActive = false
        sliderLeadingConstraint = slider.leadingAnchor.constraint(equalTo: segment.leadingAnchor)
        sliderLeadingConstraint?.isActive = true
        if animated {
            UIView.animate(withDuration: animationDuration) {
                self.stackView.layoutIfNeeded()
            }
        }
        for item in segments {
            if item.isSelected {
                item.isSelected = false
            }
        }
        segment.isSelected = true
        selectedSegmentIndex = index
    }

    public func selectSegment(at index: Int, animated: Bool) {
        let segmentItem = segments[index]
        selectSegment(segmentItem, at: index, animated: animated)
    }

    @objc
func tap(_ sender: UIControl) {
        for item in segments.enumerated() {
            if sender == item.element {
                selectSegment(item.element, at: item.offset)
                break
            }
        }
    }
}

private extension Array where Element == String {
    func segments() -> [SygicSegmentedControlItem] {
        var views = [SygicSegmentedControlItem]()
        let strings = self
        for text in strings {
            let label = SygicSegmentedControlText()
            label.text = text
            views.append(label)
        }
        return views
    }
}
