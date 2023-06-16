import UIKit

// MARK: - MultiIconSelectorDelegate

protocol MultiIconSelectorDelegate: AnyObject {
    func didSelectControl(at index: Int)
}

// MARK: - MultiIconSelector

class MultiIconSelector: UIView {
    weak var delegate: MultiIconSelectorDelegate?

    lazy var stackView: UIStackView = {
       let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.spacing = 30
        sv.alignment = .fill
        return sv
    }()

    private let items: [MultiIconItem]

    var currentSelection: Int = 0 {
        willSet {
            items[currentSelection].isSelected = false
        }
        didSet {
            items[currentSelection].isSelected = true
        }
    }

    init(with items: [MultiIconItem]) {
        self.items = items
        if let firstSelected = items.firstIndex(where: { $0.isSelected == true }) {
            currentSelection = firstSelected
        }
        super.init(frame: .zero)
        setupLayout()
        items.forEach { $0.delegate = self }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        cover(with: stackView, insets: NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
        items.forEach {
            stackView.addArrangedSubview($0)
        }
    }
}

// MARK: MultiIconItemDelegate

extension MultiIconSelector: MultiIconItemDelegate {
    func didTap(item: MultiIconItem) {
        item.isSelected = true
        if let firstIndex = items.firstIndex(where: { $0 == item }) {
            if currentSelection != firstIndex {
                (stackView.arrangedSubviews[currentSelection] as? MultiIconItem)?.isSelected = false
                currentSelection = firstIndex
                //tell the delegate
                delegate?.didSelectControl(at: currentSelection)
            }
        }
    }
}

// MARK: - MultiIconItemDelegate

protocol MultiIconItemDelegate: AnyObject {
    func didTap(item: MultiIconItem)
}

// MARK: - MultiIconItem

class MultiIconItem: UIControl {
    weak var delegate: MultiIconItemDelegate?
    private let kWidthHeight: CGFloat = 56
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 30).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return iv
    }()

    init(image: UIImage, selected: Bool = false) {
        super.init(frame: .zero)
        imageView.image = image
        setupLayout()
        layer.cornerRadius = kWidthHeight / 2
        layer.masksToBounds = true
        isSelected = selected
        addTarget(self, action: #selector(MultiIconItem.tapped), for: .touchUpInside)
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = Styling.buttonBackgroundTertiaryActive
                imageView.tintColor = Styling.buttonForegroundTertiaryActive
            } else {
                backgroundColor = UIColor.black.withAlphaComponent(0.8)
                imageView.tintColor = Styling.buttonForegroundPrimary
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted == true ? Styling.highlightedStateAlpha : 1
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        widthAnchor.constraint(equalToConstant: kWidthHeight).isActive = true
        heightAnchor.constraint(equalToConstant: kWidthHeight).isActive = true
        addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    @objc
private func tapped() {
        delegate?.didTap(item: self)
    }
}
