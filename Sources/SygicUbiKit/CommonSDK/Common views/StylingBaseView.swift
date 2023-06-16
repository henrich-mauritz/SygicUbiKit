import UIKit

open class StylingBaseView: UIView {
    public lazy var topContent: UIView = {
        let view = UIView()
        view.frame.size.height = topContentHeight
        return view
    }()

    public lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: tableStyle)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.tableFooterView = UIView()
        addSubview(table)
        return table
    }()

    open var tableStyle: UITableView.Style = .plain

    public let gradientView: GradientDrawView = {
        let gradient = GradientDrawView()
        gradient.isUserInteractionEnabled = false
        gradient.locations = [0.0, 1.0]
        return gradient
    }()

    public let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .foregroundPrimary
        return indicator
    }()

    public let mapIndicator: MapExpandIndicator = {
        let mapIndicator = MapExpandIndicator()
        mapIndicator.iconView.image = UIImage(named: "mapExpand", in: .module, compatibleWith: nil)
        return mapIndicator
    }()

    private let topContentHeight: CGFloat = 250

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupGradient()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupColorsForGradient()
    }

    public func mapIndicatorShow() {
        guard mapIndicator.isHidden else { return }
        mapIndicator.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.mapIndicator.alpha = 1.0
        }, completion: { _ in
            self.mapIndicator.isHidden = false
        })
    }

    public func mapIndicatorHide() {
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.mapIndicator.alpha = 0.0
        }, completion: { _ in
            self.mapIndicator.isHidden = true
        })
    }

    private func setupConstraints() {
        backgroundColor = .backgroundPrimary
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = topContent

        var constraints = [tableView.leadingAnchor.constraint(equalTo: leadingAnchor)]
        constraints.append(tableView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: bottomAnchor))

        NSLayoutConstraint.activate(constraints)
    }

    public func showActivityIndicator(_ show: Bool) {
        if show {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }

    private func setupGradient() {
        setupColorsForGradient()
        mapIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(activityIndicator)
        gradientView.addSubview(mapIndicator)
        topContent.addSubview(gradientView)
        var constraints = [NSLayoutConstraint]()
        constraints.append(gradientView.leadingAnchor.constraint(equalTo: topContent.leadingAnchor))
        constraints.append(gradientView.trailingAnchor.constraint(equalTo: topContent.trailingAnchor))
        constraints.append(gradientView.heightAnchor.constraint(equalToConstant: 118))
        constraints.append(gradientView.bottomAnchor.constraint(equalTo: topContent.bottomAnchor))
        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: gradientView.centerXAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor, constant: 20))
        constraints.append(mapIndicator.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor))
        constraints.append(mapIndicator.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -25))
        NSLayoutConstraint.activate(constraints)
    }

    private func setupColorsForGradient() {
        gradientView.colors = [UIColor.backgroundPrimary.withAlphaComponent(0), .backgroundPrimary]
    }
}
