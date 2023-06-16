import UIKit

class DrivingStatusView: UIStackView {
    var viewState: StatusState = .loading {
        willSet {
            switch newValue {
            case .loading:
                loadingState()
            case let .tripScored(score: scoreValue):
                serverValueState(value: scoreValue)
            default:
                removeAllSubviews()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        alignment = .center
        axis = .vertical
        loadingState()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func serverValueState(value: Double) {
        removeAllSubviews()
        let staticText = createStatusLabel(with: "driving.summary.resultText".localized)
        staticText.font = .stylingFont(.regular, with: 16)
        let scoreLabel = createStatusLabel(with: Format.scoreFormatted(value: value))
        scoreLabel.font = .stylingFont(.bold, with: 60)
        addArrangedSubview(staticText)
        addArrangedSubview(scoreLabel)
    }

    private func timeOutState() {
        removeAllSubviews()
        addArrangedSubview(createStatusLabel(with: "driving.summary.resultTextInProgress".localized))
    }

    private func offlineState() {
        removeAllSubviews()
        addArrangedSubview(createStatusLabel(with: "driving.summary.resultTextOffline".localized))
    }

    private func errorState(message: String) {
        removeAllSubviews()
        addArrangedSubview(createStatusLabel(with: message))
    }

    private func loadingState() {
        removeAllSubviews()
        let loading = UIActivityIndicatorView()
        loading.style = .large
        loading.startAnimating()
        addArrangedSubview(loading)
    }

    private func removeAllSubviews() {
        for subview in arrangedSubviews {
            removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

    private func createStatusLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.textColor = .foregroundDriving
        label.font = .stylingFont(.bold, with: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = text
        label.adjustsFontSizeToFitWidth = true
        return label
    }
}
