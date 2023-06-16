import UIKit

// MARK: - PendingTripTableViewCellDelegate

public protocol PendingTripTableViewCellDelegate: AnyObject {
    func confirmAsDriverTapped(for cell: PendingTripTableViewCell)
    func confirmAsPassangerTapped(for cell: PendingTripTableViewCell)
    func tryAgainTapped(for cell: PendingTripTableViewCell)
    func carPickerDidTap(for cell: PendingTripTableViewCell)
}

// MARK: - PendingTripTableViewCell

public class PendingTripTableViewCell: UITableViewCell {
    public weak var delegate: PendingTripTableViewCellDelegate?

    public var viewModel: PendingTripCellPresentable?

    //MARK: - Controls & Contianers

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.heightAnchor.constraint(equalToConstant: 104).isActive = true
        view.layer.cornerRadius = Styling.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()

    public lazy var checkMarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .white
        button.setImage(UIImage(named: "check", in: .module, compatibleWith: nil), for: .normal)
        button.backgroundColor = .positivePrimary
        return button
    }()

    public lazy var crossButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .white
        button.backgroundColor = .negativePrimary
        button.setImage(UIImage(named: "close", in: .module, compatibleWith: nil), for: .normal)
        return button
    }()

    public let cityLabel: UILabel = {
        let label = UILabel()
        //label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textColor = .foregroundSecondary
        return label
    }()

    public let dateLabel: UILabel = {
        let label = UILabel()
        //label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.textColor = .foregroundSecondary
        return label
    }()

    public let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .foregroundSecondary
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let errorView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView

    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "triplog.pendingTrip.errorTitle".localized
        label.textColor = .foregroundSecondary
        label.textAlignment = .center
        label.font = UIFont.stylingFont(.bold, with: 14)
        return label
    }()

    private lazy var tryAgainButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.plain)
        button.titleLabel.font = UIFont.stylingFont(.bold, with: 16)
        button.titleLabel.text = "triplog.pendingTrip.tryAgainButton".localized.uppercased()
        button.titleLabel.textColor = Styling.buttonForegroundPrimary
        button.addTarget(self, action: #selector(tryAgainPressed(sender:)), for: .touchUpInside)
        return button
    }()

    private lazy var vehiclePicker: VPVehicleSelectorControl = {
        let control = VPVehicleSelectorControl(with: .plain, controlSize: .big, icon: VehicleType.car.icon, title: "HONDA")
        control.configureForPlainStyle(with: .left)
        let windowWidth = UIWindow.windowWidth
        if let widhtConstraint = control.widthLayoutConstraint {
            NSLayoutConstraint.deactivate([widhtConstraint])
            control.widthAnchor.constraint(equalToConstant: (windowWidth - 32) * 0.4).isActive = true
        }
        
        control.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        control.addTarget(self, action: #selector(Self.carPickerTap), for: .touchUpInside)
        return control
    }()

    //MARK: - StackViews implementation

    private lazy var mainVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var topVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 2
        return stackView
    }()

    private lazy var bottomHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 0)
        return stackView
    }()

    private var bottomContainerView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()

    override public func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
        if vehiclePicker.superview == nil {
            bottomHorizontalStackView.insertArrangedSubview(vehiclePicker, at: 0)
            bottomHorizontalStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 0)
        }
    }

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .backgroundPrimary
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(with viewModel: PendingTripCellPresentable) {
        cityLabel.text = viewModel.address != "" ? viewModel.address : "triplog.pendingTrip.locationPlaceholder".localized
        dateLabel.text = "\(viewModel.date), \(viewModel.time)"
        self.viewModel = viewModel
        toggleHiddenButtons(value: viewModel.status == .markingAsPassanger)
        if viewModel.status == .failed {
            mainVerticalStackView.isHidden = true
        } else {
            mainVerticalStackView.isHidden = false
        }
        errorView.isHidden = !mainVerticalStackView.isHidden
        if let vehicle = viewModel.selectedVehicle {
            //configure the vehiclepicker
            vehiclePicker.configure(with: vehicle.vehicleType.icon, title: vehicle.name.uppercased())
        } else {
            bottomHorizontalStackView.removeArrangedSubview(vehiclePicker)
            vehiclePicker.removeFromSuperview()
            bottomHorizontalStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        }
    }

    //MARK: - Layout

    private func setupLayout() {
        contentView.cover(with: containerView, insets: NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        containerView.cover(with: mainVerticalStackView)
        bottomContainerView.cover(with: bottomHorizontalStackView)
        bottomContainerView.addSubview(activityIndicator)
        mainVerticalStackView.addArrangedSubview(topVerticalStackView)
        mainVerticalStackView.addArrangedSubview(bottomContainerView)
        topVerticalStackView.addArrangedSubview(cityLabel)
        topVerticalStackView.addArrangedSubview(dateLabel)
        bottomHorizontalStackView.addArrangedSubview(vehiclePicker)
        bottomHorizontalStackView.addArrangedSubview(crossButton)
        bottomHorizontalStackView.addArrangedSubview(checkMarkButton)
        checkMarkButton.widthAnchor.constraint(equalTo: crossButton.widthAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: bottomContainerView.centerXAnchor).isActive = true
        setupErrorStateLayout()
        checkMarkButton.addTarget(self, action: #selector(checkPressed(sender:)), for: .touchUpInside)
        crossButton.addTarget(self, action: #selector(crossPressed(sender:)), for: .touchUpInside)
    }

    private func setupErrorStateLayout() {
        //Set up the errorStackView
        errorView.isHidden = true
        contentView.cover(with: containerView, insets: NSDirectionalEdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
        errorView.addArrangedSubview(errorLabel.containedInView(with: NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)))
        let buttonContainerView = tryAgainButton.containedInView(with: .zero)
        buttonContainerView.backgroundColor = Styling.actionPrimary
        buttonContainerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        errorView.addArrangedSubview(buttonContainerView)
        containerView.cover(with: errorView, insets: NSDirectionalEdgeInsets(top: 11, leading: 0, bottom: 0, trailing: 0))
    }

    //MARK: - Actions

    public func confirmPendingTrip() {
        checkPressed()
    }
    
    @objc
func checkPressed(sender: Any) {
        checkPressed()
    }

    @objc
func crossPressed(sender: Any) {
        guard let delegate = delegate else { return }
        delegate.confirmAsPassangerTapped(for: self)
        toggleHiddenButtons(value: true)
    }

    @objc
func tryAgainPressed(sender: Any) {
        delegate?.tryAgainTapped(for: self)
    }

    @objc
func carPickerTap() {
        delegate?.carPickerDidTap(for: self)
    }

    //MARK: - Behavior
    
    private func checkPressed() {
        guard let delegate = delegate else { return }
        delegate.confirmAsDriverTapped(for: self)
        toggleHiddenButtons(value: true)
    }

    private func toggleHiddenButtons(value: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            //To let animation we set alpha value and not isHidden property
            let newAlpha: CGFloat = value == true ? 0 : 1
            self?.bottomHorizontalStackView.alpha = newAlpha
        }
        if value == true {
            activityIndicator.startAnimating()
            //bottomContainerView.dividerPositions = []
        } else {
            activityIndicator.stopAnimating()
            //configureDividers()
        }
    }
}

// MARK: - PendingTripBottomDividerView

private class PendingTripBottomDividerView: UIView {
    var dividerPositions: [CGFloat] = [] {
        didSet {
            layer.setNeedsDisplay()
            layer.displayIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIGraphicsGetCurrentContext()?.clear(rect)
        Styling.backgroundPrimary.set()
        let topLine = UIBezierPath()
        topLine.lineWidth = 1
        topLine.move(to: .zero)
        topLine.addLine(to: CGPoint(x: bounds.maxX, y: 0))
        topLine.stroke()
        for currentX in dividerPositions {
            let fromPoint = CGPoint(x: currentX, y: 0)
            let toPoint = CGPoint(x: currentX, y: bounds.maxY)
            let line = UIBezierPath()
            line.lineWidth = 1
            line.move(to: fromPoint)
            line.addLine(to: toPoint)
            line.stroke()
            line.close()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setNeedsDisplay()
    }
}
