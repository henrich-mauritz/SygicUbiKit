import UIKit
@_implementationOnly import YoutubePlayer

// MARK: - NewsDetailViewProtocol

protocol NewsDetailViewProtocol {
    func update(with detailViewModel: NewsDetailViewModelType)
    func startAnimatingLoading()
    func endAnimatingLoading()
}

protocol NewsDetailViewDelegate: AnyObject {
    func backButtonTapped()
}

// MARK: - NewsDetailView

/// NewsDetailView:  Presents the detail of teh news
/// It hs embeeded a Youtube player in case there is a youtube video to show
class NewsDetailView: UIView {
    //MARK: - Properties

    weak var delegate: NewsDetailViewDelegate?
    
    lazy private var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .buttonBackgroundTertiaryPassive
        button.tintColor = .buttonForegroundTertiaryPassive
        button.layer.cornerRadius = 40 / 2
        button.setImage(UIImage(named: "backIcon", in: .module, compatibleWith: nil), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let backgroundPreviewContainer: UIView = {
        let bgView = UIView(frame: .zero)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = .clear
        bgView.heightAnchor.constraint(equalToConstant: 225).isActive = true
        bgView.clipsToBounds = true
        return bgView
    }()
    
    private let statusBarGradient: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundPrimary.withAlphaComponent(0.5)
        return view
    }()

    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let youtubePlayer: YTPlayerView = {
        let player: YTPlayerView = YTPlayerView(frame: .zero)
        player.translatesAutoresizingMaskIntoConstraints = false
        return player
    }()
    
    private let youtubePlayerOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        view.isUserInteractionEnabled = false
        return view
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0)
        tv.scrollIndicatorInsets = tv.contentInset
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = UITableView.automaticDimension
        tv.sectionHeaderHeight = UITableView.automaticDimension
        return tv
    }()

    private var viewModel: NewsDetailViewModelType? {
        didSet {
            let hasVideo = viewModel?.videoIdentifier != nil
            backgroundPreviewContainer.isHidden = false
            youtubePlayer.isHidden = !hasVideo
            newsImageView.isHidden = hasVideo
        }
    }

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.tintColor = .foregroundPrimary
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var currentVideoID: String = ""

    //MARK: -  LifeCycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundPrimary
        setupLayout()
        configureTableView()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    private func setupLayout() {
        addSubview(backgroundPreviewContainer)
        backgroundPreviewContainer.cover(with: youtubePlayer, insets: .zero, toSafeArea: false)
        youtubePlayer.cover(with: youtubePlayerOverlay, insets: .zero, toSafeArea: false)
        backgroundPreviewContainer.cover(with: newsImageView, insets: .zero, toSafeArea: false)
        addSubview(tableView)
        addSubview(activityIndicator)
        addSubview(backButton)
//        addSubview(statusBarGradient) // planujeme v buducnosti toto dat do buildu
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backgroundPreviewContainer.topAnchor.constraint(equalTo: topAnchor, constant: -1),
            backgroundPreviewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundPreviewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: backgroundPreviewContainer.bottomAnchor, constant: -70),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
//            statusBarGradient.topAnchor.constraint(equalTo: topAnchor),
//            statusBarGradient.leadingAnchor.constraint(equalTo: leadingAnchor),
//            statusBarGradient.trailingAnchor.constraint(equalTo: trailingAnchor),
//            statusBarGradient.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func backButtonTapped() {
        self.delegate?.backButtonTapped()
    }

    //MARK: - TableView Config

    private func configureTableView() {
        tableView.register(NewsTitleSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsTitleSectionHeaderView.identifier)
        tableView.register(NewsDetailTableViewCell.self, forCellReuseIdentifier: NewsDetailTableViewCell.identifier)
    }

    func startAnimatingLoading() {
        activityIndicator.startAnimating()
    }

    func endAnimatingLoading() {
        activityIndicator.stopAnimating()
    }
    
    private func configure(youtubeID: String?) {
        if let youtubeID = youtubeID {
            let playerVars: [String: Any] = [
                "playsinline": 0,
                "rel": 0,
                "modestbranding": 1,
                "controls": 0,
                "origin": "http://www.youtube.com",
            ]
            if youtubeID != currentVideoID {
                currentVideoID = youtubeID
                youtubePlayer.load(withVideoId: youtubeID, playerVars: playerVars)
            }
            youtubePlayer.isHidden = false
            youtubePlayer.bringSubviewToFront(youtubePlayerOverlay)
        } else {
            youtubePlayer.isHidden = true
        }
    }
    
}

// MARK: NewsDetailViewProtocol

extension NewsDetailView: NewsDetailViewProtocol {
    func update(with detailViewModel: NewsDetailViewModelType) {
        if let youtubeId = detailViewModel.videoIdentifier {
            configure(youtubeID: youtubeId)
            endAnimatingLoading()
        } else if let imageUri = detailViewModel.currentSchemeImageUri {
            UIImage.loadImage(from: imageUri) {[weak self] uri, image, _ in
                if uri == imageUri {
                    self?.newsImageView.image = image
                }
                self?.endAnimatingLoading()
            }
        } else {
            endAnimatingLoading()
        }
        viewModel = detailViewModel
        tableView.reloadData()
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate

extension NewsDetailView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewModel = self.viewModel else { return nil }
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsTitleSectionHeaderView.identifier) as? NewsTitleSectionHeaderView {
            headerView.configure(with: viewModel.title)
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let newsDescription = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.identifier) as? NewsDetailTableViewCell {
            if let attString = viewModel?.htmlDocumentText {
                newsDescription.updateDescription(with: attString)
            } else {
                newsDescription.updateDescription(with: viewModel?.description)
            }
            return newsDescription
        }
        return UITableViewCell()
    }
    
}
