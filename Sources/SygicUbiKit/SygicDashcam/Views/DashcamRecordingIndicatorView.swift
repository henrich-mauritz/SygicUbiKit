import UIKit

// MARK: - DashcamRecordingIndicatorView

public final class DashcamRecordingIndicatorView: UIView {
    private let recDotView: UIView = UIView()

    private var blickCounter: Int = 0

    private var blickTimer: Timer? {
        willSet {
            blickTimer?.invalidate()
        }
    }

    override public var isHidden: Bool {
        didSet {
            if isHidden {
                blickTimer = nil
            } else {
                setupTimer()
            }
        }
    }

    private let sideMargin: CGFloat = 10
    private let height: CGFloat = 28
    private let recDotSize: CGFloat = 12

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    deinit {
        blickTimer = nil
    }
}

// MARK: - Private

private extension DashcamRecordingIndicatorView {
    func setupTimer() {
        guard blickTimer == nil else { return }

        blickTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateBlickerUI), userInfo: nil, repeats: true)
    }

    @objc
    func updateBlickerUI() {
        blickCounter += 1
        recDotView.backgroundColor = blickCounter % 2 == 0 ? .negativePrimary : .clear
    }

    func setupUI() {
        recDotView.backgroundColor = .negativePrimary
        layer.cornerRadius = height / 2
        addBlur()

        recDotView.layer.cornerRadius = recDotSize / 2

        let recLabel = UILabel()
        recLabel.font = UIFont.stylingFont(.regular, with: 20)
        recLabel.text = "dashcam.recordingIndicator".localized.uppercased()
        recLabel.textColor = .foregroundDriving

        addAutoLayoutSubviews(recDotView, recLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height),
            recDotView.centerYAnchor.constraint(equalTo: centerYAnchor),
            recDotView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sideMargin),
            recDotView.heightAnchor.constraint(equalToConstant: recDotSize),
            recDotView.widthAnchor.constraint(equalToConstant: recDotSize),
            recLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            recLabel.leadingAnchor.constraint(equalTo: recDotView.trailingAnchor, constant: 8),
            recLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -sideMargin),
        ])
    }
}
