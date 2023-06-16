import Foundation

// MARK: - BadgesListViewModelDelegate

public protocol BadgesListViewModelDelegate: AnyObject {
    func viewModelDidUpdate(viewModel: BadgesListViewModelType)
    func viewModelDidFail(viewModel: BadgesListViewModelType, error: Error)
}

// MARK: - BadgesListViewModel

class BadgesListViewModel: BadgesListViewModelType, InjectableType {
    //MARK: - Properties

    public weak var delegate: BadgesListViewModelDelegate?
    public private(set) var badgeList: [BadgeItemType]?
    private lazy var repository: BadgesRepositoryType = container.resolveBadgesRepo()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification(_:)), name: .newBadgeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - BadgesListViewModelType

    public func loadData(purginCache: Bool) {
        repository.loadData(purginCache: true) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .success(items):
                self.badgeList = items
                self.delegate?.viewModelDidUpdate(viewModel: self)
            case let .failure(error):
                self.badgeList = nil
                self.delegate?.viewModelDidFail(viewModel: self, error: error)
            }
        }
    }

    @objc
private func receiveNotification(_ notification: NSNotification) {
        loadData(purginCache: true)
    }
}
