import Foundation

// MARK: - DashcamCrashDetector

final class DashcamCrashDetector {
    var crashDetected: VoidBlock?

    private var timer: Timer?
    private var crashLevel: Double = 0
    private var crashTime: Date?
    private let motion = DashcamCrashDetectorMotion()

    func setEnabled(_ enabled: Bool) {
        motion.enableHitTest(enabled)

        if enabled {
            stopTimer()
            startTimer()
        } else {
            stopTimer()
        }
    }
}

private extension DashcamCrashDetector {
    var crashed: Bool {
        guard let crashTime = crashTime else { return false }
        // Observe crash 5 seconds after crash.
        return -crashTime.timeIntervalSinceNow >= 5 ? true : false
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(handleCrash), userInfo: nil, repeats: true)
        timer?.fire()
    }

    func stopTimer() {
        timer?.invalidate()
    }

    func updateCrashLevel() {
        crashLevel = motion.hitTest

        if crashLevel >= 1, crashTime == nil {
            crashTime = Date()
        }
    }

    @objc
    func handleCrash() {
        updateCrashLevel()

        if crashed {
            crashDetected?()
        }
    }
}
