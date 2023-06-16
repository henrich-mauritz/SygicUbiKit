import UIKit

// MARK: - TripDetailReportView

class TripDetailReportView: UIView, TripDetailReportViewProtocol {
    public weak var delegate: TripDetailReportViewDelegate?

    public var viewModel: TripDetailReportViewModelProtocol? {
        didSet {
            guard let speedLimit = viewModel?.speedLimit else { return }
            currentSpeedLabel.text = "\(Int(speedLimit)) km/h"
        }
    }

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let title: UILabel = {
        let label = UILabel()
        label.text = "triplog.report.title".localized
        label.numberOfLines = 2
        label.font = .stylingFont(.bold, with: 32)
        label.textColor = .foregroundPrimary
        label.heightAnchor.constraint(equalToConstant: 82).isActive = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let speedText: UILabel = {
        let label = UILabel()
        label.text = "triplog.report.currentSpeedLimit".localized
        label.font = .stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        return label
    }()

    private let currentSpeedLabel: UILabel = {
        let label = UILabel()
        label.font = .stylingFont(.bold, with: 16)
        label.text = "0 km/h"
        label.textColor = .foregroundPrimary
        return label
    }()

    private let correctSpeedLimitText: UILabel = {
        let label = UILabel()
        label.text = "triplog.report.correctSpeedLimit".localized
        label.font = .stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        return label
    }()

    private lazy var correctSpeedLimitTextView: UITextView = {
        let view = UITextView()
        view.keyboardType = .numberPad
        view.textColor = UIColor.foregroundSecondary.withAlphaComponent(0.5)
        view.font = .stylingFont(.regular, with: 16)
        view.textAlignment = .center
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = Styling.cornerRadius
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        view.delegate = self
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        view.widthAnchor.constraint(equalToConstant: 66).isActive = true
        return view
    }()

    private let requiredSpeedLimitText: UILabel = {
        let label = UILabel()
        label.text = "triplog.report.speedLimitRequired".localized
        label.font = .stylingFont(.regular, with: 14)
        label.textColor = .negativePrimary
        label.isHidden = true
        return label
    }()

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.text = "triplog.report.describe".localized
        view.textColor = UIColor.foregroundSecondary.withAlphaComponent(0.5)
        view.font = .stylingFont(.regular, with: 16)
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = Styling.cornerRadius
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.textContainerInset = UIEdgeInsets(top: 18, left: 23, bottom: 23, right: 18)
        view.delegate = self
        view.heightAnchor.constraint(equalToConstant: 127).isActive = true
        return view
    }()

    private let requiredDescriptionText: UILabel = {
        let label = UILabel()
        label.text = "triplog.report.descriptionRequired".localized
        label.font = .stylingFont(.regular, with: 14)
        label.textColor = .negativePrimary
        label.isHidden = true
        return label
    }()

    private var textInputString: String = "triplog.report.describe".localized

    private lazy var charCounter: UILabel = {
        let text = UILabel()
        text.text = "0/\(descriptionMaxLength)"
        text.font = UIFont.stylingFont(.thin, with: 14)
        text.textColor = .foregroundPrimary
        return text
    }()

    private let legalText: UILabel = {
        let text = UILabel()
        let companyName = Bundle.companyName ?? ""
        text.text = String(format: "triplog.report.disclaimer".localized, companyName)
        text.numberOfLines = 3
        text.font = .itemTitleFont()
        text.textColor = .foregroundPrimary
        text.adjustsFontSizeToFitWidth = true
        return text
    }()

    lazy private var cancelButton: StylingButton = {
        let cancel = StylingButton.button(with: .secondary)
        cancel.titleLabel.text = "triplog.report.cancelButton".localized.uppercased()
        cancel.addTarget(self, action: #selector(cancelTap), for: .touchUpInside)
        return cancel
    }()

    lazy private var sendButton: StylingButton = {
        let send = StylingButton.button(with: .normal)
        send.titleLabel.text = "triplog.report.sendButton".localized.uppercased()
        send.addTarget(self, action: #selector(submitTap), for: .touchUpInside)
        send.isEnabled = false
        return send
    }()

    private let buttons: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 8
        return stack
    }()

    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .foregroundPrimary
        return indicator
    }()

    private let speedMaxLength: Int = 3

    private let descriptionMaxLength: Int = 120

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundPrimary
        setupSelectors()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
        scrollView.contentOffset.y = (buttons.frame.origin.y + buttons.frame.size.height) - keyboardFrame.origin.y
    }

    @objc
func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.contentOffset.y = .zero
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        title.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16 + safeAreaInsets.top).isActive = true
    }

    @objc
private func cancelTap(_ sender: Any) {
        delegate?.reportCanceled()
    }

    @objc
private func submitTap(_ sender: Any) {
        if validateInputs() {
            cancelButton.isEnabled = false
            sendButton.isEnabled = false
            isUserInteractionEnabled = false
            showActivityIndicator(true)
            let speedLimit: Int = Int(correctSpeedLimitTextView.text) ?? 0
            viewModel?.reportSpeedLimit(textView.text, speedLimit: speedLimit, completion: { [weak self] result in
                if case .success = result {
                    self?.sendButton.isEnabled = true
                }
                self?.cancelButton.isEnabled = true
                self?.isUserInteractionEnabled = true
                self?.showActivityIndicator(false)
                self?.delegate?.reportSubmited(result: result)
            })
        } else {
            wrongInput()
        }
    }

    private func validateInputs() -> Bool {
        let descriptionText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if descriptionText != textInputString && !descriptionText.isEmpty && !correctSpeedLimitTextView.text.isEmpty {
            return true
        }
        return false
    }

    private func showActivityIndicator(_ show: Bool) {
        if show {
            if activityIndicator.superview == nil {
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                addSubview(activityIndicator)
                activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            }
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }

    private func wrongInput() {
        if correctSpeedLimitTextView.text.isEmpty {
            correctSpeedLimitTextView.layer.borderColor = UIColor.negativePrimary.cgColor
            requiredSpeedLimitText.isHidden = false
        } else {
            correctSpeedLimitTextView.layer.borderColor = UIColor.clear.cgColor
            requiredSpeedLimitText.isHidden = true
        }
        if textView.text.isEmpty || textView.text == textInputString {
            textView.layer.borderColor = UIColor.negativePrimary.cgColor
            requiredDescriptionText.isHidden = false
        } else {
            textView.layer.borderColor = UIColor.clear.cgColor
            requiredDescriptionText.isHidden = true
        }
        delegate?.wrongInput()
    }

    private func setupSelectors() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    private func setupConstraints() {
        title.translatesAutoresizingMaskIntoConstraints = false
        speedText.translatesAutoresizingMaskIntoConstraints = false
        currentSpeedLabel.translatesAutoresizingMaskIntoConstraints = false
        correctSpeedLimitText.translatesAutoresizingMaskIntoConstraints = false
        correctSpeedLimitTextView.translatesAutoresizingMaskIntoConstraints = false
        requiredSpeedLimitText.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        requiredDescriptionText.translatesAutoresizingMaskIntoConstraints = false
        legalText.translatesAutoresizingMaskIntoConstraints = false
        buttons.translatesAutoresizingMaskIntoConstraints = false
        charCounter.translatesAutoresizingMaskIntoConstraints = false

        buttons.addArrangedSubview(cancelButton)
        buttons.addArrangedSubview(sendButton)
        scrollView.addSubview(title)
        scrollView.addSubview(speedText)
        scrollView.addSubview(currentSpeedLabel)
        scrollView.addSubview(correctSpeedLimitText)
        scrollView.addSubview(correctSpeedLimitTextView)
        scrollView.addSubview(requiredSpeedLimitText)
        scrollView.addSubview(charCounter)
        scrollView.addSubview(textView)
        scrollView.addSubview(requiredDescriptionText)
        scrollView.addSubview(legalText)
        scrollView.addSubview(buttons)
        addSubview(scrollView)
        cover(with: scrollView)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))
        constraints.append(title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -133))

        constraints.append(speedText.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 33))
        constraints.append(speedText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))

        constraints.append(currentSpeedLabel.centerYAnchor.constraint(equalTo: speedText.centerYAnchor))
        constraints.append(currentSpeedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))

        constraints.append(correctSpeedLimitText.topAnchor.constraint(equalTo: speedText.bottomAnchor, constant: 33))
        constraints.append(correctSpeedLimitText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))

        constraints.append(correctSpeedLimitTextView.centerYAnchor.constraint(equalTo: correctSpeedLimitText.centerYAnchor))
        constraints.append(correctSpeedLimitTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))

        constraints.append(requiredSpeedLimitText.topAnchor.constraint(equalTo: correctSpeedLimitTextView.bottomAnchor, constant: 5))
        constraints.append(requiredSpeedLimitText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))

        constraints.append(textView.topAnchor.constraint(equalTo: correctSpeedLimitText.bottomAnchor, constant: 44))
        constraints.append(textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))
        constraints.append(textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))

        constraints.append(charCounter.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: Styling.cornerRadius))
        constraints.append(charCounter.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 3))

        constraints.append(requiredDescriptionText.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 5))
        constraints.append(requiredDescriptionText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))

        constraints.append(legalText.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 23))
        constraints.append(legalText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))
        constraints.append(legalText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))

        constraints.append(buttons.topAnchor.constraint(equalTo: legalText.bottomAnchor, constant: 30))
        constraints.append(buttons.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))
        constraints.append(buttons.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))
        constraints.append(buttons.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20))

        NSLayoutConstraint.activate(constraints)
    }

    @objc
private func dismissKeyboard() {
        textView.endEditing(true)
        correctSpeedLimitTextView.endEditing(true)
    }
}

// MARK: UITextViewDelegate

extension TripDetailReportView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.textView && textView.text == textInputString {
            textView.text = nil
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == self.textView && textView.text.isEmpty {
            textView.text = textInputString
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let charCount = textView.text.count + (text.count - range.length)
        sendButton.isEnabled = validateInputs()
        if textView == self.textView {
            charCounter.text = "\(min(charCount, descriptionMaxLength))/\(descriptionMaxLength)"
            return charCount <= descriptionMaxLength
        } else if textView == self.correctSpeedLimitTextView {
            return charCount <= speedMaxLength
        }
        return true
    }
}
