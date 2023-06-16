import Foundation
import UIKit

// MARK: - VisionCalibrationViewViewModelDelegate

protocol VisionCalibrationViewViewModelDelegate: AnyObject {
    func calibrationViewModelShouldRotate(at angle: Double)
    func calibrationViewModelDidMatchHorizon()
    //func beginEducationAnimation(completion: @escaping () -> ())
}

// MARK: - VisionCalibrationViewViewModel

class VisionCalibrationViewViewModel {
    private let kMaxAngleForCalibration: Double = 15

    weak var delegate: VisionCalibrationViewViewModelDelegate?

    var shouldEducate: Bool {
        let nomralizedAngle = normalizeRadAngle(angle: currentRadAngle ?? 0)
        return dashcamCalibrationManager.motionAvaiable && (nomralizedAngle > kMaxAngleForCalibration)
    }

    private(set) var currentRadAngle: Double? {
        didSet {
            guard let angle = currentRadAngle else {
                return
            }
            let degreesAngle = normalizeRadAngle(angle: angle)
            if degreesAngle > kMaxAngleForCalibration {
                delegate?.calibrationViewModelShouldRotate(at: degreesAngle)
            } else {
                delegate?.calibrationViewModelDidMatchHorizon()
            }
        }
    }

    private lazy var dashcamCalibrationManager: DashcamVisionCalibrationManager = {
        let manager = DashcamVisionCalibrationManager.shared
        manager.delegate = self
        return manager
    }()

    var arrowImage: UIImage? {
        guard let currentRadAngle = currentRadAngle else { return nil }
        var image: UIImage?
        if currentRadAngle < -5 {
            if UIDevice.current.orientation.isLandscape {
                image = UIImage(named: "arrow_left", in: .module, compatibleWith: nil)
            } else {
                image = UIImage(named: "arrow_right", in: .module, compatibleWith: nil)
            }
        } else {
            if UIDevice.current.orientation == .landscapeRight {
                if currentRadAngle < 0 {
                    image = UIImage(named: "arrow_right", in: .module, compatibleWith: nil)
                } else {
                    image = UIImage(named: "arrow_left", in: .module, compatibleWith: nil)
                }
            } else {
                if !UIDevice.current.orientation.isLandscape {
                    image = UIImage(named: "arrow_left", in: .module, compatibleWith: nil)
                } else {
                    image = UIImage(named: "arrow_right", in: .module, compatibleWith: nil)
                }
            }
        }
        return image
    }

    private func normalizeRadAngle(angle: Double) -> Double {
        var degreesAngle = Double.rad2Deg(angle)
        if degreesAngle < 0 {
            degreesAngle += 360
        }
        return degreesAngle
    }

    public func startCalibrating() {
        dashcamCalibrationManager.startAnalyzingAngle()
    }

    public func stopCalibrating() {
        dashcamCalibrationManager.stopAnalyzingAngle()
    }
    
    public var isCalibrating: Bool {
        dashcamCalibrationManager.updatingMotion
    }
    
}

// MARK: DashcamVisionCalibrationManagerDelegate

extension VisionCalibrationViewViewModel: DashcamVisionCalibrationManagerDelegate {
    public func motionCalibrationManagerDidChnage(to pitchAngle: Double) {
        currentRadAngle = pitchAngle
    }
}
