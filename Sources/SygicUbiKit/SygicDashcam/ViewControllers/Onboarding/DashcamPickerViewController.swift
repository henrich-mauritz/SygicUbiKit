import UIKit

// MARK: - DashcamPickerViewController

final class DashcamPickerViewController: UIViewController {
    private let contentView = UIView()
    private let headerView = UIView()
    private let picker = UIPickerView()
    private let doneButton = UIButton()
    private let headerHeight: CGFloat = 44.0
    private let sideMargin: CGFloat = 16.0
    private let animationDuration: TimeInterval = 0.2

    private var viewModel: DashcamPickerViewModelProtocol?
    private var contentViewBottomConstraint = NSLayoutConstraint()

    override var shouldAutorotate: Bool {
        false
    }

    init(with viewModel: DashcamPickerViewModelProtocol, delegate: DashcamOnboardingPickerDelegate) {
        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel
        self.viewModel?.pickerDelegate = delegate

        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doneButtonPressed)))
        setupContent()

        picker.reloadAllComponents()
        if let selectedItemIndex = viewModel.selectedItemIndex {
            picker.selectRow(selectedItemIndex, inComponent: 0, animated: true)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private

private extension DashcamPickerViewController {
    func setupContent() {
        contentView.backgroundColor = .backgroundPrimary
        view.addAutoLayoutSubviews(contentView)
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        contentViewBottomConstraint.isActive = true

        setupContentHeader()
        setupPicker()
        picker.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
    }

    func setupContentHeader() {
        view.addAutoLayoutSubviews(headerView)
        headerView.backgroundColor = .backgroundPrimary
        headerView.addBorderShadow()

        headerView.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
        contentView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true

        setupDoneButton()
    }

    func setupPicker() {
        picker.delegate = self
        picker.dataSource = self

        contentView.addAutoLayoutSubviews(picker)

        contentView.leadingAnchor.constraint(equalTo: picker.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: picker.trailingAnchor).isActive = true
        contentView.safeAreaBottomAnchor.constraint(equalTo: picker.bottomAnchor).isActive = true
    }

    func setupDoneButton() {
        doneButton.backgroundColor = .clear
        headerView.addAutoLayoutSubviews(doneButton)

        doneButton.setTitleColor(DashcamColorManager.shared.blue, for: .normal)
        doneButton.setTitleColor(DashcamColorManager.shared.blue.withAlphaComponent(0.3), for: .highlighted)
        doneButton.setTitleShadowColor(.clear, for: .normal)
        doneButton.titleLabel?.textAlignment = .center
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneButton.setTitle("dashcam.settings.pickerClose".localized, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        doneButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        doneButton.trailingAnchor.constraint(equalTo: headerView.safeAreaTrailingAnchor, constant: -sideMargin).isActive = true
        doneButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
    }

    @objc
    func doneButtonPressed() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: UIPickerViewDataSource, UIPickerViewDelegate

extension DashcamPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel?.numberOfItems ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel?.didSelect(index: row)
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if let string = viewModel?.title(for: row) {
            return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.foregroundPrimary])
        }

        return nil
    }
}
