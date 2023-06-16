import Foundation
import UIKit

extension TripEvent {
    var animations: DriveAnimations? {
        switch event.eventType {
        case .acceleration:
            return AcceleratingAnimations()
        case .braking:
            return BrakingAnimations()
        case .cornering:
            if event.eventCurrentSize > 0 {
                return CorneringLeftAnimations()
            } else {
                return CorneringRightAnimations()
            }
        default:
            return nil
        }
    }
}

// MARK: - DrivingAnimationsManager

public class DrivingAnimationsManager {
    weak var imageView: UIImageView?

    var animationsEnabled: Bool = true

    var currentEvent: TripEvent?

    var nextEvent: TripEvent?

    var defaultAnimations: DrivingAnimations?

    private var animations = [AnimationData]()

    private var testAnimations: [AnimationData] = [
        DrivingStartAnimation(),
        DrivingAnimation(),
        CorneringLeftStartAnimation(),
        CorneringLeftAnimation(),
        CorneringLeftEndAnimation(),
        DrivingAnimation(),
        CorneringRightStartAnimation(),
        CorneringRightAnimation(),
        CorneringRightEndAnimation(),
        BrakingStartAnimation(),
        BrakingAnimation(),
        BrakingEndAnimation(),
        DrivingAnimation(),
        AcceleratingStartAnimation(),
        AcceleratingAnimation(),
        AcceleratingEndAnimation(),
        DrivingAnimation(),
        DrivingEndAnimation(),
    ]

    private var animationTimer: Timer? {
        willSet {
            if let timer = animationTimer, timer.isValid {
                timer.invalidate()
            }
        }
    }

    private var playTestAnimations: Bool = false

    private var appInBackgroind: Bool = false

    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func play(_ tripEvent: TripEvent? = nil, for vehicleType: VehicleType = .car) {
        guard vehicleType != .motorcycle else {
            return
        }
        guard !appInBackgroind, animationsEnabled else { return }
        if playTestAnimations {
            animations = testAnimations
            playAnimation()
            playTestAnimations = false
            return
        }
        guard let tripEvent = tripEvent, let tripAnimations = tripEvent.animations else {
            playDefaultDrivingAnimation()
            return
        }
        if currentEvent == nil {
            currentEvent = tripEvent
            queueAnimation(tripAnimations.startAnimation)
            queueAnimation(tripAnimations.animation)
        } else if tripEvent == currentEvent && tripEvent.status == .ended {
            queueAnimation(tripAnimations.endAnimation)
        } else if tripEvent != currentEvent && tripEvent != nextEvent {
            queueAnimation(currentEvent?.animations?.endAnimation)
            nextEvent = tripEvent
        }
    }

    public func stopAnimations(animated: Bool = true, for vehicleType: VehicleType = .car) {
        guard vehicleType != .motorcycle else {
            return
        }
        if let finishAnimation = defaultAnimations?.endAnimation, animated, animationsEnabled {
            queueAnimation(finishAnimation)
        } else {
            animationTimer = nil
            animations.removeAll()
        }
        currentEvent = nil
        nextEvent = nil
        defaultAnimations = nil
    }

    private func playNextEvent() {
        guard animationsEnabled else { return }
        currentEvent = nextEvent
        nextEvent = nil
        guard let event = currentEvent, let nextAnimations = event.animations else {
            playDefaultDrivingAnimation()
            return
        }
        queueAnimation(nextAnimations.startAnimation)
        queueAnimation(nextAnimations.animation)
    }

    func playAnimation() {
        while let firstLoop = animations.first, firstLoop.loop, animations.count > 1 {
            animations.removeFirst()
        }
        guard let animation = animations.first, let imageView = imageView, animationsEnabled else { return }
        let images = animation.assets
        let imageCount = images.count
        let duration = Double(imageCount) / Double(animation.fps)
        let frameTime: TimeInterval = duration / Double(imageCount)

        var index: Int = 0
        if animation.loop {
            imageView.animationImages = images
            imageView.animationDuration = duration
            imageView.startAnimating()
            return
        } else {
            imageView.stopAnimating()
            imageView.animationImages = nil
            imageView.image = images.first
        }
        animationTimer = Timer.scheduledTimer(withTimeInterval: frameTime, repeats: true) { [weak self] timer in
            guard timer.isValid else { return }
            guard index < images.count else {
                self?.animationDidStop(animation)
                return
            }
            let image = images[index]
            imageView.image = image
            index += 1
        }
    }

    private func animationDidStop(_ animation: AnimationData) {
        animationTimer = nil
        if animation.part == .end {
            currentEvent = nil
        }
        if animation.loop && animations.count <= 1 {
            playAnimation()
        } else {
            animations.removeFirst()
            if animations.first != nil {
                playAnimation()
            } else {
                playNextEvent()
            }
        }
    }

    private func playDefaultDrivingAnimation() {
        nextEvent = nil
        guard let defaultAnimations = defaultAnimations, animations.last != defaultAnimations.animation, animationsEnabled else { return }
        if let endingAnimation = currentEvent?.animations?.endAnimation, !animations.contains(endingAnimation) {
            queueAnimation(endingAnimation)
        }
        if let firstLooping = animations.first, firstLooping.loop {
            animationDidStop(firstLooping)
        }
        if animationTimer == nil {
            if currentEvent == nil {
                queueAnimation(defaultAnimations.startAnimation)
            }
            queueAnimation(defaultAnimations.animation)
        } else {
            queueAnimation(defaultAnimations.animation)
        }
    }

    private func queueAnimation(_ animation: AnimationData?) {
        guard let toQueue = animation, animationsEnabled else { return }
        if animations.count > 1, animations.last == defaultAnimations?.animation {
            _ = animations.popLast() // kick default driving animation if another animation want queue
        }
        guard animations.last != toQueue else {
            return
        }
        animations.append(toQueue)
        if animations.count > 1, let queuedFirst = animations.first, queuedFirst == defaultAnimations?.animation {
            // stop and kick playing default driving animation if another animation is queued
            animationTimer?.invalidate()
            animationDidStop(queuedFirst)
        }
        if animations.count == 1 && animationTimer == nil {
            playAnimation()
        }
    }

    public func pauseAnimations() {
        animationTimer?.invalidate()
    }

    public func resumeAnimations() {
        guard animationsEnabled else { return }
        if animations.count > 0 {
            playAnimation()
        }
    }

    @objc
func appWillResignActive() {
        appInBackgroind = true
        pauseAnimations()
    }

    @objc
func appWillBecomeActive() {
    appInBackgroind = false
    resumeAnimations()
    }
}
