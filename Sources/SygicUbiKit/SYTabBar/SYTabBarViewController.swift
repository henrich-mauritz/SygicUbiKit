import UIKit

open class SYTabBarViewController: UIViewController {
    public var tabs = [SYTabBarItem]() {
        didSet {
            updateTabs()
        }
    }

    public let tabBarView = SYTabBarView()
    public let contentHolder = UIView()
    public let bannerHolder = UIView()
    public var contentChildController: UIViewController?
    private let bannerHeight: CGFloat = 64

    public var seletedTabIndex: Int? {
        let index = tabs.firstIndex { $0.isSelected == true }
        return index
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentHolder)
        view.addSubview(tabBarView)
        view.addSubview(bannerHolder)
        setupLayoutConstraints()
    }

    override open func viewWillAppear(_ animated: Bool) {
        updateTabsNotificationBadges()
        super.viewWillAppear(animated)
    }

    open var edgeInsets: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: SYTabBarView.tabBarHeight, right: 0)
    }

    public func selectTab(_ selectedTab: SYTabBarItem) {
        updateTabsNotificationBadges()
        selectTabView(selectedTab)
        if let newController = selectedTab.contentViewController {
            switchContent(newController)
        }
    }

    public func selectTab(at index: Int) {
        guard index <= tabs.count - 1 else {
            fatalError("The index \(index) is out of bounds \(tabs.count - 1)")
        }
        selectTab(tabs[index])
    }

    private func selectFirstTab() {
        guard let first = tabs.first else { return }
        first.isSelected = true
        if let firstController = first.contentViewController {
            switchContent(firstController)
        }
    }

    private func setupLayoutConstraints() {
        contentHolder.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        bannerHolder.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentHolder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentHolder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentHolder.topAnchor.constraint(equalTo: view.topAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerHolder.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 0),
            bannerHolder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentHolder.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            tabBarView.topAnchor.constraint(equalTo: bannerHolder.bottomAnchor)
        ])
        view.layoutIfNeeded()
    }

    private func updateTabs() {
        for tab in tabs {
            tab.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        }
        tabBarView.tabs = tabs
        selectFirstTab()
    }

    private func updateTabsNotificationBadges() {
        for tab in tabs {
            if let tabController = tab.contentViewController as? SYTabBarContentController {
                tab.showNotificationBadge(tabController.notificationAvailable)
            }
        }
    }

    @objc
private func tabTapped(_ sender: Any) {
        guard let selectedTab = sender as? SYTabBarItem else { return }
        selectTab(selectedTab)
    }

    private func selectTabView(_ tab: SYTabBarItem) {
        guard !tab.isSelected else {
            popSelectedContentController(tab)
            return
        }
        let oldSelected = tabs.first(where: { $0.isSelected })
        tab.isSelected = true
        if let old = oldSelected {
            old.isSelected = false
            tabBarView.highlightTab(tab, oldSelected: old)
        }

        guard let selectedIndex = seletedTabIndex else { return }
        registerAnalyticForTabTapped(at: selectedIndex)
    }

    private func popSelectedContentController(_ selectedItem: SYTabBarItem) {
        guard let navigationController = selectedItem.contentViewController as? UINavigationController else { return }
        navigationController.popToRootViewController(animated: false)
    }

    private func switchContent(_ newChild: UIViewController) {
        if let oldContent = contentChildController {
            guard oldContent != newChild else { return }
            oldContent.willMove(toParent: nil)
            oldContent.view.removeFromSuperview()
            oldContent.removeFromParent()
        }
        addChild(newChild)
        newChild.additionalSafeAreaInsets = edgeInsets
        contentHolder.addSubview(newChild.view)
        setupContentChildConstraints(newChild)
        newChild.didMove(toParent: self)
        contentChildController = newChild
    }

    private func setupContentChildConstraints(_ newChild: UIViewController) {
        guard let childSuperview = newChild.view.superview else { return }
        newChild.view.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints.append(newChild.view.topAnchor.constraint(equalTo: childSuperview.topAnchor))
        constraints.append(newChild.view.bottomAnchor.constraint(equalTo: childSuperview.bottomAnchor))
        constraints.append(newChild.view.leadingAnchor.constraint(equalTo: childSuperview.leadingAnchor))
        constraints.append(newChild.view.trailingAnchor.constraint(equalTo: childSuperview.trailingAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    /// Empty implementation that allows subclasses to regisster their own analytics events upon tab tag
    /// - Parameter index: tab index
    open func registerAnalyticForTabTapped(at index: Int) {}
}
