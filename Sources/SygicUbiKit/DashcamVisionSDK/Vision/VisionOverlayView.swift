import Foundation
import UIKit
import AVFoundation
import VisionLib

// MARK: - VisionOverlayView

class VisionOverlayView: UIView {
    lazy var speedLimitView: SYSpeedLimitView = {
        let speedLimitView = SYSpeedLimitView.speedView()
        speedLimitView.isHidden = true
        return speedLimitView
    }()

    lazy var tailgatingPulsingView: DashcamVisionTailgatingView = {
        let view = DashcamVisionTailgatingView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var calibrationView: VisionCalibrationView = {
        let view = VisionCalibrationView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private var topMargin: CGFloat { DashcamControlsView.topMargin }
    private var sideMargin: CGFloat { DashcamControlsView.sideMargin }
    private var currentVehicleFrame: CGRect = .zero
    public weak var dashcamDistanceLabel: UILabel?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        VisionManager.shared.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }

    override func draw(_ rect: CGRect) {
        guard VisionManager.shared.debugEnabled else {
            return
        }
        let previewLayer = findVideoPreviewLayer(on: superview)
        let signColor = UIColor.magenta
        signColor.setStroke()
        for sign in VisionManager.shared.detectedSpeedSigns {
            let signRect: CGRect = sign.rect(to: previewLayer, or: self)
            let rect = UIBezierPath(rect: signRect)
            rect.lineWidth = 3
            rect.stroke()
            let confString: NSString = String(format: "%.1f%%", sign.signConfidence) as NSString
            confString.draw(at: signRect.origin, withAttributes: [
                .font: UIFont.stylingFont(with: 12),
                .foregroundColor: signColor,
            ])
        }
    }

    private func findVideoPreviewLayer(on view: UIView?) -> AVCaptureVideoPreviewLayer? {
        if cameraPreviewLayer != nil {
            return cameraPreviewLayer
        }
        guard let view = view else { return nil }
        if let founded = view.layer.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer }) as? AVCaptureVideoPreviewLayer {
            cameraPreviewLayer = founded
            return founded
        }
        return findVideoPreviewLayer(on: view.superview)
    }

    private func setupLayout() {
        backgroundColor = .clear
        addSubview(speedLimitView)
        cover(with: tailgatingPulsingView, toSafeArea: false)
        cover(with: calibrationView, toSafeArea: false)
        var constraints = [NSLayoutConstraint]()
        constraints.append(speedLimitView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: topMargin))
        constraints.append(speedLimitView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -sideMargin))
        constraints.append(speedLimitView.widthAnchor.constraint(equalToConstant: DashcamControlsView.speedLimitSize))
        constraints.append(speedLimitView.heightAnchor.constraint(equalToConstant: DashcamControlsView.speedLimitSize))
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: VisionModelDelegate

extension VisionOverlayView: VisionModelDelegate {
    func visionManagerDidProcessedImage() {
        setNeedsDisplay()
    }
    
    func visionManagerDidUpdateSpeedLimit(_ speedLimitVision: Double?, from source: SpeedLimitSource?) {
        guard let speedLimit = speedLimitVision,
              let source = source else {
            speedLimitView.isHidden = true
            return
        }
        print("*********  speedlimit: \(speedLimit),  source: \(source)")
        let container = SYInjector.container
        if let dashcamConfig = container.resolve(DashcamVisionConfigurable.self),
           dashcamConfig.signRecognitionEnabled {
            speedLimitView.isHidden = false
        }
        speedLimitView.updateSpeed(with: Int(speedLimit), animated: source == .vision, forceAnimation: true)
    }

    func visionManagerDidUpdateTailgating(_ isTailgating: Bool, vehicle: SYVisionVehicle?, tooClose: Bool, timeDistance: TimeInterval?) {
        guard let vehicle = vehicle else {
            tailgatingPulsingView.isHidden = true
            dashcamDistanceLabel?.alpha = 1 //need to work with alpha because the control overlays uses the hidden property
            return
        }

        var finalFrame: CGRect = vehicle.rect(to: findVideoPreviewLayer(on: superview), or: self)
        if finalFrame.maxY >= bounds.maxY {
            finalFrame = .zero
        }
        finalFrame.size.height = CGFloat(fabs(Double(finalFrame.size.height)))
        finalFrame.origin.y -= 1.5 * finalFrame.size.height
        let vehicleInfo = DashcamVisionTailgatingVehicleInfo(timeToImpact: timeDistance ?? -1, carDistance: vehicle.distance, vehicleFrame: finalFrame)
        tailgatingPulsingView.tailgatingVehicleInfo = vehicleInfo
        tailgatingPulsingView.isHidden = false
        dashcamDistanceLabel?.alpha = 0
    }

    func beginEducation() {
        calibrationView.beginEducation()
    }

    func stopEducation() {
        calibrationView.calibrationCompleted()
        calibrationView.viewModel.stopCalibrating()
        calibrationView.isHidden = true
    }
    
    func setEducation(hidden: Bool) {
        if !calibrationView.viewModel.isCalibrating && hidden == false {
            return
        }
        calibrationView.isHidden = hidden
    }
    
}
