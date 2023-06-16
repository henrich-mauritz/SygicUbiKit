import UIKit

class SegmentControllCell: UITableViewCell, SegmentedControllCellProtocol {
    public weak var delegate: SegmentedControllDelegate?

    private static let allowedPages: [TripDetailPageType] = [.map, .score]

    public var selectedSegmentIndex: Int {
        get {
            segmentedControl.selectedSegmentIndex
        }
        set {
            guard segmentedControl.selectedSegmentIndex != newValue else { return }
            segmentedControl.selectedSegmentIndex = newValue
        }
    }

    private lazy var segmentedControl: SygicSegmentedControl = {
        let items = SegmentControllCell.allowedPages.map { page -> String in
            switch page {
            case .map:
                return "module.triplog.tripDetailSummary".localized
            case .score:
                return "module.triplog.tripDetailDetails".localized
            }
        }

        let control = SygicSegmentedControl(items: items)
        control.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return control
    }()

    private let segmentedControlWidth: CGFloat = 200

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints.append(segmentedControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(segmentedControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
        constraints.append(segmentedControl.widthAnchor.constraint(equalToConstant: segmentedControlWidth))
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
private func segmentedControlValueChanged(_ sender: SygicSegmentedControl) {
        guard delegate != nil else { return }
        switch SegmentControllCell.allowedPages[sender.selectedSegmentIndex] {
        case .map:
            delegate?.switchTableContent(to: .map)
        case .score:
            delegate?.switchTableContent(to: .score)
        }
    }
}
