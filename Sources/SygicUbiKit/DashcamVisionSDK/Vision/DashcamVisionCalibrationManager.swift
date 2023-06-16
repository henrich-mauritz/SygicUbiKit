import Foundation
import UIKit
import CoreMotion

// MARK: - DashcamVisionCalibrationManagerDelegate

public protocol DashcamVisionCalibrationManagerDelegate: AnyObject {
    /// called when the motion calibration manager detets a change in phone's yaw
    /// - Parameter pitchAngle: yaw angle in rads
    func motionCalibrationManagerDidChnage(to pitchAngle: Double)
}

// MARK: - DashcamVisionCalibrationManager

public class DashcamVisionCalibrationManager {
    public static let shared: DashcamVisionCalibrationManager = DashcamVisionCalibrationManager()
    public weak var delegate: DashcamVisionCalibrationManagerDelegate?
    public var motionAvaiable: Bool {
        return coreMotionManager.isDeviceMotionAvailable
    }

    public var updatingMotion: Bool = false
    private let coreMotionManager = CMMotionManager()
    private let interval: Double = 1.0 / 60
    private var overlappingAngle: CGFloat?
    private lazy var motionQueue: OperationQueue = {
      var queue = OperationQueue()
      queue.name = "Motion queue"
      queue.maxConcurrentOperationCount = 1
      return queue
    }()

    private init() {}

    public func startAnalyzingAngle() {
        guard updatingMotion == false,
              coreMotionManager.isDeviceMotionAvailable else { return }
        coreMotionManager.deviceMotionUpdateInterval = interval
        updatingMotion = true
        coreMotionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: motionQueue) { [weak self] deviceMotion, _ in
            guard let data = deviceMotion,
            let self = self else { return }
            var angle = atan2(data.gravity.x, data.gravity.y) - Double.pi
            if UIDevice.current.orientation.isLandscape {
                if UIDevice.current.orientation == .landscapeRight {
                    angle = atan2(data.gravity.y, data.gravity.x)
                } else {
                    angle = atan2(data.gravity.y, data.gravity.x) - Double.pi
                }
            }
            DispatchQueue.main.async {
                self.delegate?.motionCalibrationManagerDidChnage(to: angle)
            }
        }
    }

    public func invalidateAngles() {
        overlappingAngle = nil
    }

    public func stopAnalyzingAngle() {
        updatingMotion = false
        coreMotionManager.stopDeviceMotionUpdates()
    }
}
