import CoreMIDI
import UIKit

//TODO: lepsie meno?
//Vsetky tieto tanecky tu mame len preto lebo delegat uipageviewcontrollera sa nevola vzdy a dostavame crashe
//kde scrollview v UIPageViewControllery sa dostane do zleho stavu a skonci to na vinimke.
protocol MyPageViewControllerDelegate: AnyObject {
    func scrollViewInsidePageViewStartedMovement()
    func scrollViewInsidePageViewEndedMovement()
}
class MyPageViewController: UIPageViewController, UIScrollViewDelegate {
    weak var myDelegate: MyPageViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        for subview in self.view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.delegate = self
                break
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        myDelegate?.scrollViewInsidePageViewStartedMovement()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        myDelegate?.scrollViewInsidePageViewEndedMovement()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        myDelegate?.scrollViewInsidePageViewEndedMovement()
    }
}


public class MultipleDrivingScreenViewController: UIViewController, MultipleDrivingScreenViewDelegate, InjectableType, UIGestureRecognizerDelegate, MyPageViewControllerDelegate {
    
    private let controllers: [MultiScreenBehavioralProtocol]
    private var currentIndex: Int = 0
    private var multipleDrivingView: MultipleDrivingScreenView {
        guard let view = self.view as? MultipleDrivingScreenView else { fatalError("This shouldn't happen")}
        return view
    }
    
    var pageControlItems: [MultiIconItem] = []
    internal lazy var pageController: UIPageViewController = {
        let controller = MyPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        controller.myDelegate = self
        controller.delegate = self
        controller.dataSource = self
        controller.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
        
        return controller
    }()

    public init(with controllers: [MultiScreenBehavioralProtocol], initialIndex: Int = 0) {
        self.controllers = controllers
        super.init(nibName: nil, bundle: nil)
        var currentIndex = 0
        controllers.forEach {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(MultipleDrivingScreenViewController.pan(gesutre:)))
            panGesture.delegate = self
            pageController.view.addGestureRecognizer(panGesture)
            $0.view.addGestureRecognizer(panGesture)
            pageControlItems.append(MultiIconItem(image: $0.pageControlIcon, selected: currentIndex == initialIndex))
            currentIndex += 1
        }
        setupController(at: initialIndex)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        
    }

    override public func loadView() {
        //TODO: Tento konstrukt je nestandardny, tahat cez delegata parent view je ...
        //ok, uz tomu chapem...ale kua..to je konstrukt..cize MultipleDrivingScreenView(delegate: self) ...managuje view..a cez delegata si cucneme pageController.view..och..ok..
        pageController.willMove(toParent: self)
        addChild(pageController)
        let v = MultipleDrivingScreenView(delegate: self)
        v.multiIconControl.delegate = self
        view = v
        pageController.didMove(toParent: self)
    }
    
    
    @objc private func pan(gesutre: UIPanGestureRecognizer) {
        //intentionaly empty
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let currentController = pageController.viewControllers?.first as? MultiScreenBehavioralProtocol else {
            return false
        }

        return !currentController.multiSceenControllerShouldSwipe(self)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func setupController(at index: Int) {
        guard index < controllers.count else { return }
        let vc = controllers[index]
        
        self.pageController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        currentIndex = index
    }

    //shouldAutorotate should always return true, because once it returns false, OS will not ask you again about rotation. In iOS16 there is new method for that. setNeedsUpdateOfSupportedInterfaceOrientations
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let currentController = controllers[self.currentIndex]
        return currentController.supportedInterfaceOrientations
    }

    override public var shouldAutorotate: Bool { return true }

    public var pageControlIsHidden: Bool {
        get {
             multipleDrivingView.multiIconControl.isHidden
        }
        set {
            multipleDrivingView.multiIconControl.isHidden = newValue
            controllers.forEach { $0.pageControlDidHide(value: newValue) }
        }
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if UIWindow.isPortrait {
            pageController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
        } else {
            pageController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        }
    }

    public func updateControlIcon(at index: Int) {
        let controller = controllers[index]
        let controlItem = pageControlItems[index]
        controlItem.imageView.image = controller.pageControlIcon
    }
    
    public func updateModel(at index: Int) {
        let controller = controllers[index]
        controller.vehicleProfileDidUpdate()
    }
    
    func scrollViewInsidePageViewEndedMovement() {
        multipleDrivingView.multiIconControl.isUserInteractionEnabled = true
    }
    
    func scrollViewInsidePageViewStartedMovement() {
        multipleDrivingView.multiIconControl.isUserInteractionEnabled = false
    }
}

// MARK: UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension MultipleDrivingScreenViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    private func indexOfViewController(viewController: UIViewController) -> Int {
        for (index, controller) in controllers.enumerated() {
            if viewController === controller {
                return index
            }
        }
        
        //tu sa realne nemozeme dostat, ale velmi sa mi tento konstrukt nepaci.
        fatalError("Tu sa realne nemozeme dostat.")
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = indexOfViewController(viewController: viewController)
        if index <= 0 {
            return nil //ziaden vc pred indexom 0
        }
        return controllers[index - 1]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = indexOfViewController(viewController: viewController)
        if index >= controllers.count - 1 {
            return nil //sme na poslednom, dalej sa ist neda
        }
        
        return controllers[index + 1]
    }

   
    //Beware: this method may not be called!
    //Steps to reproduce: move to left most page. start scrolling, but don't lift fingers from screen. Use more than 1 finger at time to move from page 0 to page 3. When on page 3, lift fingers. done.
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard let view = self.view as? MultipleDrivingScreenView else { return }
            let mapped: [UIViewController] = controllers.map { $0 as UIViewController }
            if let firstViewController = pageViewController.viewControllers?.first,
               let index = mapped.firstIndex(of: firstViewController) {
                view.multiIconControl.currentSelection = index
                currentIndex = index
            }
        }
    }

}

// MARK: MultiIconSelectorDelegate

extension MultipleDrivingScreenViewController: MultiIconSelectorDelegate {
    //programatically switch page.
    func didSelectControl(at index: Int) {
        guard currentIndex != index else { return }
        guard index >= 0 || index < controllers.count else { return }
        
        var direction: UIPageViewController.NavigationDirection = .forward
        if index < currentIndex {
            direction = .reverse
        }
                
        self.pageController.view.isUserInteractionEnabled = false
        self.currentIndex = index
        pageController.setViewControllers([controllers[index]], direction: direction, animated: true) { completed in
            if completed {
                self.pageController.view.isUserInteractionEnabled = true
            }
        }
    }
    
}
