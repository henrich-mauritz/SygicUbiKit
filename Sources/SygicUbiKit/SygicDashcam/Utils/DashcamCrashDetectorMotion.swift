import CoreMotion
import Foundation

final class DashcamCrashDetectorMotion {
    private let manager = CMMotionManager()

    private var hitTestEnabled: Bool = false
    private var hitTestResult = 0.0
    private var hitTestPrevAccel = CMAcceleration()
    private var hitTestAccumulator = 0.0
    private var hitTestRiser = 0.0

    init() {
        manager.showsDeviceMovementDisplay = true

            manager.deviceMotionUpdateInterval = 0.05
            manager.startDeviceMotionUpdates(to: OperationQueue()) { [weak self] motionData, _ in
                guard let motionData = motionData else { return }
                self?.testMotionData(motionData)
            }
    }

    var hitTest: Double {
        guard hitTestEnabled else {
            assertionFailure("Hit test not enabled")
            return 0.0
        }

        let result = hitTestResult

        if hitTestResult >= 1.0 {
            hitTestAccumulator = 0
            hitTestRiser = 0
        }

        hitTestResult = 0.0

        return result
    }

    func enableHitTest(_ enable: Bool) {
        if enable {
            hitTestResult = 0
            hitTestAccumulator = 0
            hitTestRiser = 0
        }

        hitTestEnabled = enable
    }

    private func testMotionData(_ motionData: CMDeviceMotion) {
        if self.hitTestEnabled && (self.hitTestResult < 1.0) {
            let acceleration = motionData.userAcceleration

            let delta = CMAcceleration(x: self.hitTestPrevAccel.x - acceleration.x,
                                       y: self.hitTestPrevAccel.y - acceleration.y,
                                       z: self.hitTestPrevAccel.z - acceleration.z)

            self.hitTestPrevAccel = acceleration

            var magnitude = sqrt(delta.x * delta.x + delta.y * delta.y + delta.z * delta.z)

            self.hitTestAccumulator += magnitude
            self.hitTestAccumulator *= 0.75

            if self.hitTestAccumulator > self.hitTestRiser {
                self.hitTestRiser += 0.08
            } else {
                self.hitTestRiser = self.hitTestAccumulator
            }

            magnitude = self.hitTestRiser / 4.0 // 4.0 hit threshold

            self.hitTestResult = max(self.hitTestResult, magnitude)
        }
    }
}
