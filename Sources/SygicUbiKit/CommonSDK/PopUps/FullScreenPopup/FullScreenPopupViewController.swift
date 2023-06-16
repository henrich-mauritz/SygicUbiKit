import UIKit

public class FullScreenPopupViewController: UIViewController {
    public var viewModel: StylingPopUpViewModelDataType? {
        didSet {
            guard let view = self.view as? FullScreenPopUpView else { return }
            view.viewModel = viewModel
        }
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let v = FullScreenPopUpView()
        self.view = v
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        PopupManager.shared.popupDidDisappear(self)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let view = self.view as? FullScreenPopUpView else { return }
        view.viewModel = viewModel
    }
}
