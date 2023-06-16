import UIKit

// MARK: - MultipleDrivingScreenViewDelegate

protocol MultipleDrivingScreenViewDelegate: AnyObject {
    var pageController: UIPageViewController { get }
    var pageControlItems: [MultiIconItem] { get }
}

// MARK: - MultipleDrivingScreenView

class MultipleDrivingScreenView: UIView {
    private weak var delegate: MultipleDrivingScreenViewDelegate?
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    lazy var multiIconControl: MultiIconSelector = {
        guard let delegate = delegate else {
            fatalError("The delegate wasn't set yet, plesae veryfy this")
        }
        let iconSelector = MultiIconSelector(with: delegate.pageControlItems)
        iconSelector.translatesAutoresizingMaskIntoConstraints = false
        return iconSelector
    }()

    //MARK: - LifeCycle

    required init(delegate: MultipleDrivingScreenViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        backgroundColor = .backgroundDriving
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented init with coder")
    }

    private func setupLayout() {
        guard let delegate = self.delegate else { return }
        cover(with: delegate.pageController.view, toSafeArea: false)
        addSubview(multiIconControl)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(multiIconControl.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(multiIconControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10))
        portraitConstraints = constraints
        constraints = []
        constraints.append(multiIconControl.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8))
        constraints.append(multiIconControl.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 45))
        landscapeConstraints = constraints
        activateCurrentLayout()
    }

    private func activateCurrentLayout() {
        if UIWindow.isPortrait {
            multiIconControl.stackView.axis = .horizontal
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            multiIconControl.stackView.axis = .vertical
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        activateCurrentLayout()
    }
}
