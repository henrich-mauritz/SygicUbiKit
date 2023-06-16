import UIKit

// MARK: - VPTooltipViewControllerDelegate

public protocol VPTooltipViewControllerDelegate: AnyObject {
    func toolTipPickerdidTapCarPicker()
    func toolTipPickerdidTapUnderstand()
}

// MARK: - VPTooltipViewController

public class VPTooltipViewController: UIViewController {
    public weak var delegate: VPTooltipViewControllerDelegate?

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let v = VPTooltipView()
        v.delegate = self
        self.view = v
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let view = self.view as? VPTooltipView else { return }
        view.animateIn()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

// MARK: VPTooltipViewDelegate

extension VPTooltipViewController: VPTooltipViewDelegate {
    func didTapCarControl() {
        guard let view = self.view as? VPTooltipView else { return }
        view.animateOut {
            self.dismiss(animated: true) {
                self.delegate?.toolTipPickerdidTapCarPicker()
            }
        }
    }

    func didTapUnderstand() {
        guard let view = self.view as? VPTooltipView else { return }
        view.animateOut {
            self.dismiss(animated: true) {
                self.delegate?.toolTipPickerdidTapCarPicker()
            }
        }
    }

    func didTapOutterBounds() {
        guard let view = self.view as? VPTooltipView else { return }
        view.animateOut {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
