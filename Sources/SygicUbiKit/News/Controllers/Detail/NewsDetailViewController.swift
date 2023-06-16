import UIKit

public class NewsDetailViewController: UIViewController {
    var viewModel: NewsDetailViewModelType

    private var detailView: NewsDetailViewProtocol {
        guard let v = self.view as? NewsDetailViewProtocol else {
            fatalError("The view is not a news detail view")
        }

        return v
    }

    init(with viewModel: NewsDetailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func loadView() {
        let newsDetailView = NewsDetailView(frame: .zero)
        newsDetailView.delegate = self
        view = newsDetailView
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.largeTitleDisplayMode = .never
        guard let detailToLoad = viewModel.detailIdToLoad else { return }
        detailView.startAnimatingLoading()
        viewModel.loadDetail(with: detailToLoad) { finished in
            if finished {
                //update the view
                self.detailView.update(with: self.viewModel)
            } else {
                self.presentErrorView(with: MessageViewModel.viewModel(with: .error))
            }
        }
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard UIApplication.shared.applicationState == .active else { return }
        updateAppearance()
    }

    @objc
private func applicationDidBecomeActive() {
        updateAppearance()
    }

    private func updateAppearance() {
        // update NSAttributedString appearence
        viewModel.refreshHtmlDocumentText { [weak self] in
            guard let self = self else { return }
            self.detailView.update(with: self.viewModel)
        }
    }
}

extension NewsDetailViewController: NewsDetailViewDelegate {
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
