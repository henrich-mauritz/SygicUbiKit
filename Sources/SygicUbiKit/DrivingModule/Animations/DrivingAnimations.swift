import Foundation
import UIKit

// MARK: - AnimationDataProtocol

public protocol AnimationDataProtocol {
    var assetsName: String { get }
    var loop: Bool { get }
    var reverse: Bool { get }
    var part: AnimationPart { get }
    var assets: [UIImage] { get }
}

// MARK: - AnimationPart

public enum AnimationPart {
    case start, loop, end
}

// MARK: - AnimationData

public class AnimationData: Equatable, AnimationDataProtocol, InjectableType {
    public enum AnimationAssetNameKey: String {
        case intro, drive, accelerate, cornering_left, cornering_right, braking
    }

    public var assetsName: String = ""
    public var loop: Bool = false
    public var reverse: Bool = false
    public var part: AnimationPart = .loop

    public var assets: [UIImage] {
        if let imageAssets = container.resolve([UIImage].self, name: assetsName) {
            if reverse {
                return imageAssets.reversed()
            }
            return imageAssets
        }
        return [UIImage]()
    }

    public static func == (lhs: AnimationData, rhs: AnimationData) -> Bool {
        return lhs.assetsName == rhs.assetsName &&
            lhs.loop == rhs.loop &&
            lhs.reverse == rhs.reverse &&
            lhs.part == rhs.part
    }
}

public extension AnimationData {
    //Driving
    static let introAssetNameKey: String = "intro"
    static let driveAssetNameKey: String = "drive"
    static let driveEndAssetNameKey: String = "driveEnd"

    //Acceleration
    static let accelerateStartAssetNameKey: String = "accelerate_start"
    static let accelerateAssetNameKey: String = "accelerate"
    static let accelerateEndAssetNameKey: String = "accelerate_end"

    //CornerLeft
    static let corneringLeftStartAssetNameKey: String = "cornering_left_start"
    static let corneringLeftAssetNameKey: String = "cornering_left"
    static let corneringLeftEndAssetNameKey: String = "cornering_left_end"

    //CornerRigjt
    static let corneringRightStartAssetNameKey: String = "cornering_right_start"
    static let corneringRightAssetNameKey: String = "cornering_right"
    static let corneringRightEndAssetNameKey: String = "cornering_right_end"

    //Braking
    static let brakingStartAssetNameKey: String = "brakingStart"
    static let brakingEndAssetNameKey: String = "brakingEnd"
    static let brakingAssetNameKey: String = "braking"
}

extension AnimationDataProtocol {
    public var assets: [UIImage] {
        let assets = [UIImage]()
        return assets
    }

    func isEqual(_ otherAnimation: AnimationData) -> Bool {
        return assetsName == otherAnimation.assetsName && reverse == otherAnimation.reverse
    }

    var fps: Int { 40 }

    //var duration: TimeInterval { Double(assetsCount)/Double(fps) }
}

// MARK: - DrivingStartAnimation

class DrivingStartAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.introAssetNameKey
        part = .start
    }
}

// MARK: - DrivingAnimation

class DrivingAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.driveAssetNameKey
        loop = true
    }
}

// MARK: - DrivingEndAnimation

class DrivingEndAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.driveEndAssetNameKey
        reverse = true
        part = .end
    }
}

// MARK: - BrakingStartAnimation

class BrakingStartAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.brakingStartAssetNameKey
        part = .start
    }
}

// MARK: - BrakingAnimation

class BrakingAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.brakingAssetNameKey
        loop = true
    }
}

// MARK: - BrakingEndAnimation

class BrakingEndAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.brakingEndAssetNameKey
        part = .end
    }
}

// MARK: - CorneringLeftStartAnimation

class CorneringLeftStartAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.corneringLeftStartAssetNameKey
        part = .start
    }
}

// MARK: - CorneringLeftAnimation

class CorneringLeftAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.corneringLeftAssetNameKey
        loop = true
    }
}

// MARK: - CorneringLeftEndAnimation

class CorneringLeftEndAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.corneringLeftEndAssetNameKey
        part = .end
    }
}

// MARK: - AcceleratingStartAnimation

class AcceleratingStartAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.accelerateStartAssetNameKey
        part = .start
    }
}

// MARK: - AcceleratingAnimation

class AcceleratingAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.accelerateAssetNameKey
        loop = true
    }
}

// MARK: - AcceleratingEndAnimation

class AcceleratingEndAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.accelerateEndAssetNameKey
        part = .end
    }
}

// MARK: - CorneringRightStartAnimation

class CorneringRightStartAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.corneringRightStartAssetNameKey
        part = .start
    }
}

// MARK: - CorneringRightAnimation

class CorneringRightAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.corneringRightAssetNameKey
        loop = true
    }
}

// MARK: - CorneringRightEndAnimation

class CorneringRightEndAnimation: AnimationData {
    override init() {
        super.init()
        assetsName = AnimationData.corneringRightEndAssetNameKey
        part = .end
    }
}

// MARK: - DriveAnimations

protocol DriveAnimations {
    var startAnimation: AnimationData? { get }
    var animation: AnimationData { get }
    var endAnimation: AnimationData? { get }
}

// MARK: - DrivingAnimations

struct DrivingAnimations: DriveAnimations {
    var startAnimation: AnimationData? = DrivingStartAnimation()
    var animation: AnimationData = DrivingAnimation()
    var endAnimation: AnimationData? = DrivingEndAnimation()
}

// MARK: - AcceleratingAnimations

struct AcceleratingAnimations: DriveAnimations {
    var startAnimation: AnimationData? = AcceleratingStartAnimation()
    var animation: AnimationData = AcceleratingAnimation()
    var endAnimation: AnimationData? = AcceleratingEndAnimation()
}

// MARK: - BrakingAnimations

struct BrakingAnimations: DriveAnimations {
    var startAnimation: AnimationData? = BrakingStartAnimation()
    var animation: AnimationData = BrakingAnimation()
    var endAnimation: AnimationData? = BrakingEndAnimation()
}

// MARK: - CorneringLeftAnimations

struct CorneringLeftAnimations: DriveAnimations {
    var startAnimation: AnimationData? = CorneringLeftStartAnimation()
    var animation: AnimationData = CorneringLeftAnimation()
    var endAnimation: AnimationData? = CorneringLeftEndAnimation()
}

// MARK: - CorneringRightAnimations

struct CorneringRightAnimations: DriveAnimations {
    var startAnimation: AnimationData? = CorneringRightStartAnimation()
    var animation: AnimationData = CorneringRightAnimation()
    var endAnimation: AnimationData? = CorneringRightEndAnimation()
}
