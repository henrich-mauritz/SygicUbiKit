import CoreMotion
import SceneKit
import UIKit

// MARK: - TailgatingViewDefaults

public struct TailgatingViewDefaults: TailgatingConfigurable {
    public var tailgatingEvent: TailgatingEventType
    public var closeColor: TailgatingGradientable = TailgatingDefaultGradient(beginColor: Styling.negativePrimary, endColor: Styling.negativePrimary.withAlphaComponent(0))
    public var farColor: TailgatingGradientable = TailgatingDefaultGradient(beginColor: Styling.positivePrimary, endColor: Styling.positivePrimary.withAlphaComponent(0))
    public init(with tailgatingEvent: TailgatingEventType) {
        self.tailgatingEvent = tailgatingEvent
    }
}

// MARK: - TailgatingDefaultGradient

public struct TailgatingDefaultGradient: TailgatingGradientable {
    public var beginColor: UIColor
    public var endColor: UIColor
}

// MARK: - TailgateDefaultEvent

public struct TailgateDefaultEvent: TailgatingEventType {
    /// frame in screen coordinates
    public var carFrame: CGRect
    /// distnce in meters
    public var carDistance: Double
    /// time to impact in seconds
    public var timeToImpact: Double
    /// whether the car is too close or no
    public var isTooClose: Bool
    /// initialized of the defaults event
    /// - Parameters:
    ///   - carFrame: frame in screen coordinates
    ///   - carDistance: distnce in meters
    ///   - timeToImpact: time to impact in seconds
    ///   - isTooClose: whether the car is too close or no
    public init(with carFrame: CGRect, carDistance: Double, timeToImpact: Double, isTooClose: Bool) {
        self.carDistance = carDistance
        self.carFrame = carFrame
        self.timeToImpact = timeToImpact
        self.isTooClose = isTooClose
    }
}

// MARK: - TailgatingView

public class TailgatingView: UIView {
    public var debugOverlay: Bool = false

    private var animationDuration: Double = 1
    private var frequency: Double = 0.8

    //MARK: - Constants

    private let turnAngle: CGFloat = 12
    private let pitchAngle: CGFloat = 3
    private let scaleX: Double = 0.7

    //MARK: -  properties

    private lazy var sceneView: SCNView = {
        let view = SCNView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private lazy var scene: SCNScene = {
        let bundle = Bundle(for: TailgatingView.self)
        let scnURL = bundle.resourceURL?.appendingPathComponent("TailgatingArt.bundle/art.scnassets/Tailgate.scn")

        do {
            let scn = try SCNScene(url: scnURL!, options: nil)
            scn.background.contents = UIColor.clear
            return scn
        } catch {
            fatalError("somethign really bad happened")
        }
    }()

    private lazy var cameraNode: SCNNode = {
        let node = SCNNode()
        node.camera = camera
        node.position = SCNVector3(x: 0, y: 2, z: 1)
        let rotX = Double.deg2rad(-10)
        node.eulerAngles = SCNVector3(CGFloat(rotX), 0, 0)
        return node
    }()

    private lazy var camera: SCNCamera = {
        let cam = SCNCamera()
        cam.usesOrthographicProjection = false
        return cam
    }()

    private lazy var tailingShape: TailingShape = {
        let plane = TailingShape.shape()
        let beginColor = Styling.eventBraking
        let endColor = Styling.eventBraking.withAlphaComponent(0)
        let material = GradientMaterial(size: CGSize(width: 200, height: 200),
                                        color1: CIColor(cgColor: beginColor.cgColor),
                                        color2: CIColor(cgColor: endColor.cgColor))
        plane.materials = [material]
        return plane
    }()

    private lazy var tailingNode: SCNNode = {
        let node = SCNNode(geometry: tailingShape)
        node.name = "planeNode"
        node.opacity = 0.6
        node.pivot = SCNMatrix4MakeTranslation(0, -1, 0)
        node.scale = SCNVector3(scaleX, 1, 0)
        node.position = SCNVector3(0, 0, 0)
        return node
    }()

    private lazy var containerNode: SCNNode = {
        let node = SCNNode()
        node.name = "container"
        node.addChildNode(tailingNode)
        node.position = SCNVector3(0, 0, 0)
        node.pivot = SCNMatrix4MakeTranslation(0, -1, 0)
        node.eulerAngles = SCNVector3(CGFloat(Double.deg2rad(-90)), 0, 0)
        return node
    }()

    private lazy var motion: CMMotionManager = {
        CMMotionManager()
    }()

    private var animating: Bool = false
    private var animationTimer: Timer?
    private var willAnimateshrink: Bool = false
    private var tooClose: Bool = false
    private var prevBottomMidPoint: CGPoint = .zero
    private var prevAngle: Float = 0.0
    /**
     These 2 are a woraround so the tailgate appears without problem for first time
     */
    private var nInitialAnimations = 0
    private var firstTimeTurnAnimation: Bool { return nInitialAnimations < 5 }

    public var viewModel: TailgatingConfigurable? {
        didSet {
            guard let viewModel = self.viewModel else {
                tooClose = false
                return
            }
            if viewModel.isTooClose {
                self.frequency = 0.4
                self.animationDuration = 0.6
            } else {
                self.frequency = 0.8
                self.animationDuration = 1.0
            }
            configureVisuals()
            tooClose = viewModel.isTooClose
            setNeedsDisplay()
        }
    }

    //MARK: - Lifecycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        cover(with: sceneView)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(containerNode)
        sceneView.scene = scene
        if motion.isDeviceMotionAvailable {
            motion.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical)
            motion.deviceMotionUpdateInterval = 1.0 / 60.0
        }
    }

    private var initialAttitude: CMAttitude?

    /// Configure the plane node visuals, internally this method calls the tail distance, color and turnTo method
    private func configureVisuals() {
        guard let viewModel = self.viewModel else {
            return
        }

        var fromColor: TailgatingGradientable!
        var toColor: TailgatingGradientable!
        var animated = true

        if !tooClose && viewModel.isTooClose {
            fromColor = viewModel.farColor
            toColor = viewModel.closeColor
        } else if tooClose && viewModel.isTooClose {
            fromColor = viewModel.closeColor
            toColor = viewModel.closeColor
            animated = false
        } else if tooClose && !viewModel.isTooClose {
            fromColor = viewModel.closeColor
            toColor = viewModel.farColor
        } else if !tooClose && !viewModel.isTooClose {
            fromColor = viewModel.farColor
            toColor = viewModel.farColor
            animated = false
        }

        setTailTo(viewModel.worldDistance, oldColor: fromColor, newColor: toColor, animated: animated)
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        guard debugOverlay else { return }
        let context = UIGraphicsGetCurrentContext()
        context?.clear(self.bounds)
        guard let viewModel = self.viewModel, viewModel.tailgatingEvent.carFrame != .zero else { return }
        let path = UIBezierPath(rect: viewModel.tailgatingEvent.carFrame)
        context?.setLineWidth(2)
        let debugColor = UIColor.green
        context?.setStrokeColor(debugColor.cgColor)
        let distanceString = String(format: "%.2fs..%.1fm", viewModel.tailgatingEvent.timeToImpact, viewModel.tailgatingEvent.carDistance)
        (distanceString as NSString).draw(at: viewModel.tailgatingEvent.carFrame.origin,
                                          withAttributes: [
                                              .font: UIFont.stylingFont(with: 12),
                                              .foregroundColor: debugColor,
                                          ])
        path.stroke()
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        animateArrows()
    }

    /// Convert the points on the screen to the 3D scene
   private func convertToScenOf(point: CGPoint) -> SCNVector3 {
        let Z_Far: CGFloat = 0.1
        let Screen_Aspect: CGFloat = UIScreen.main.bounds.size.width > 400 ? 0.3 : 0.0
        // Calculate the distance from the edge of the screen
        let Y = tan(Double(camera.fieldOfView / 180 / 2) * Double.pi) * Double(Z_Far - Screen_Aspect)
        let X = tan(Double(camera.fieldOfView / 2 / 180) * Double.pi) * Double(Z_Far - Screen_Aspect) * Double(self.bounds.size.width / self.bounds.size.height)
        let alphaX = 2 * CGFloat(X) / self.bounds.size.width
        let alphaY = 2 * CGFloat(Y) / self.bounds.size.height
        let x = -CGFloat(X) + point.x * alphaX
        let y = CGFloat(Y) - point.y * alphaY
        let target = SCNVector3Make(Float(x), Float(y), Float(-Z_Far))
        return sceneView.pointOfView?.convertPosition(target, to: scene.rootNode) ?? .init(x: 0, y: 0, z: 0)
   }
}

//MARK: - Animation

extension TailgatingView {
    private func scheduleTimeAnimation(with interval: Double, duration: Double) {
        if animating {
            beginArowAnimations() //Initial call to show first aniamtion immediatly
            animationTimer = Timer.scheduledTimer(withTimeInterval: interval,
                                                  repeats: true) {[self] _ in
                self.beginArowAnimations(duration: duration)
            }
        }
    }

    private func beginArowAnimations(duration: Double = 1) {
        guard willAnimateshrink == false else { return }

        let arrowShape = SCNPlane(width: 0.7, height: 0.7)
        let arrowMaterial = SCNMaterial()
        let zPosition: Float = 0.7
        arrowMaterial.lightingModel = .lambert
        arrowMaterial.diffuse.contents = viewModel?.slidingImage
        arrowMaterial.shininess = 100
        arrowMaterial.transparency = 0.15
        arrowMaterial.transparencyMode = .default
        arrowMaterial.blendMode = .screen
        arrowShape.materials = [arrowMaterial]

        let arrowNode = SCNNode(geometry: arrowShape)
        arrowNode.opacity = 0
        arrowNode.pivot = SCNMatrix4MakeTranslation(0, 0.5, 0)
        arrowNode.position = SCNVector3(0, tailingNode.scale.y, zPosition)
        containerNode.addChildNode(arrowNode)

        let apearAction = SCNAction.fadeIn(duration: duration)
        let action = SCNAction.move(to: SCNVector3(0, -1.3, zPosition), duration: duration)
        let group = SCNAction.group([apearAction, action])
        let removeAction = SCNAction.removeFromParentNode()
        let sequecnce = SCNAction.sequence([group, removeAction])
        arrowNode.runAction(sequecnce)
    }

    /// Begin arrow animation
    public func animateArrows() {
        if animating {
            return
        }
        animating = true
        if animationTimer != nil {
            animationTimer?.invalidate()
            animationTimer = nil
        }
        scheduleTimeAnimation(with: frequency, duration: animationDuration)
    }

    /// Stops arrows animation, whatever running animation shall complete
    public func stopArrowAnimation() {
        animating = false
        animationTimer?.invalidate()
        animationTimer = nil
    }

    /// Set the tailing shape to the new worldDistance value, and changes its color animated
    /// - Parameters:
    ///   - worldDistance: new worldDistance
    ///   - oldColor: old color gradient description
    ///   - newColor: to color gradient description
    ///   - animated: if should animate, this parameter affects only the color animation, The grow animation its affected by the viewModels animateTransitionProperty
    public func setTailTo(_ worldDistance: Double, oldColor: TailgatingGradientable, newColor: TailgatingGradientable, animated: Bool = false) {
        let material = tailingNode.geometry!.firstMaterial! //by configuration this doesn't changes and will be valid

        if animated == false {
            let image = GradientMaterial.imageGradient(size: CGSize(width: 200, height: 200),
                                                       color1: CIColor(cgColor: newColor.beginColor.cgColor),
                                                       color2: CIColor(cgColor: newColor.endColor.cgColor), direction: .Up)
            material.diffuse.contents = image
        } else {
            let changecolorAction = SCNAction.customAction(duration: animationDuration) { _, elapsedTime in
                let percentage = elapsedTime / CGFloat(self.animationDuration)
                let currentAnimBeginColor = GradientMaterial.aniColor(from: oldColor.beginColor, to: newColor.beginColor, percentage: percentage)
                let currentAnimEndColor = GradientMaterial.aniColor(from: oldColor.endColor, to: newColor.endColor, percentage: percentage)
                let image = GradientMaterial.imageGradient(size: CGSize(width: 200, height: 200),
                                                           color1: CIColor(cgColor: currentAnimBeginColor.cgColor),
                                                           color2: CIColor(cgColor: currentAnimEndColor.cgColor), direction: .Up)
                material.diffuse.contents = image
            }
            tailingNode.runAction(changecolorAction)
        }
        setTailTo(worldDistance: worldDistance)
    }

    /// Set the new tail worldDistance only, no color involved here, if you wann change the colors, please uses setTailTo(_ worldDistance:Double, oldColor:TailgatingGradientable, newColor: TailgatingGradientable, animated:Bool = false)
    /// - Parameters:
    ///   - newworldDistance: new distnace
    ///   - animated: if shall animate the tail
    public func setTailTo(worldDistance: Double) {
        guard let viewModel = self.viewModel else { return }

        if !viewModel.animateTransitions {
            tailingNode.scale = SCNVector3(scaleX, worldDistance, 1)
            self.animationTimer?.invalidate()
            self.animationTimer = nil
            self.scheduleTimeAnimation(with: self.frequency, duration: self.animationDuration)
            self.willAnimateshrink = false
            return
        }

        if firstTimeTurnAnimation || !viewModel.animateTransitions {
            tailingNode.scale = SCNVector3(scaleX, worldDistance, 1)
            turnAndPitch()
            nInitialAnimations += 1
        } else {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = animationDuration
            tailingNode.scale = SCNVector3(scaleX, worldDistance, 1)
            turnAndPitch()
            SCNTransaction.commit()
        }
    }

    /// Takes into account the event frame, calculates an angle based on the max default angle turnAngle and turns the plane node
    private func turnAndPitch() {
            turnTo()
        //pitch()
    }

    private func turnTo() {
        guard let viewModel = self.viewModel else { return }

        let finalFrame = viewModel.tailgatingEvent.carFrame
        let rotationAngle = rotate(finalFrame.midX)
        let xEuler = self.containerNode.eulerAngles.x
        let yAngle = Float(Math.deg2rad(Double(-rotationAngle)))
        self.containerNode.eulerAngles = SCNVector3(xEuler, yAngle, 0.0)
    }

    func rotate(_ middlePoint: CGFloat, onYAxis: Bool = true) -> CGFloat {
        let screenHalf = onYAxis ? frame.size.width / 2 : frame.size.height / 2
        let constraintAngle = onYAxis ? turnAngle : pitchAngle
        var rotationAngle: CGFloat = 0
        if middlePoint < screenHalf {
            let relativePosition = (middlePoint / screenHalf) - 1
            rotationAngle = relativePosition * constraintAngle
        } else {
            let relativePosition = (middlePoint - screenHalf) / screenHalf
            rotationAngle = CGFloat(relativePosition) * constraintAngle
        }
        return rotationAngle
    }
}

// MARK: SCNSceneRendererDelegate

//MARK: - SCNSceneRendererDelegate

extension TailgatingView: SCNSceneRendererDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let attitude = motion.deviceMotion?.attitude, let initialAttitude = self.initialAttitude else {
            self.initialAttitude = self.motion.deviceMotion?.attitude
            return
        }
        attitude.multiply(byInverseOf: initialAttitude)
        let maxAngle = Float(Math.deg2rad(-10))
        let minAngle = Float(Math.deg2rad(-2))
        let currentAngle = attitude.pitch / 10 //random number to make the step smaller
        let cameraAngle = cameraNode.eulerAngles.x
        var finalAngle: Float = cameraAngle + Float(currentAngle)
        finalAngle = finalAngle < maxAngle ? maxAngle : finalAngle
        finalAngle = finalAngle > minAngle ? minAngle : finalAngle
        cameraNode.eulerAngles.x = Float(finalAngle)
    }
}
