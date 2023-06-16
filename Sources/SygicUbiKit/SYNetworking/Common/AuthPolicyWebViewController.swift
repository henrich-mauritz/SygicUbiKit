import Foundation
import WebKit

// MARK: - AuthPolicyWebViewControllerDelegate

public protocol AuthPolicyWebViewControllerDelegate: AnyObject {
    func authorizationSuccessfull()
}

// MARK: - AuthPolicyWebViewController

open class AuthPolicyWebViewController: UIViewController {
    public var shouldShowNavigationBar: Bool = true {
        didSet {
            navigationController?.setNavigationBarHidden(!shouldShowNavigationBar, animated: true)
        }
    }

    public var signInDomain: B2cClientAuth.SignInType?

    public private(set) var authPolicy: B2cClientAuth.Policy = .signIn

    public var originalPolicy: B2cClientAuth.Policy = .signIn

    private let signInWithAppleRedirect: String? = Bundle.main.infoDictionary?["SIGNIN_WITH_APPLE_REDIRECT"] as? String

    private let signInWithFacebookRedirect: String? = Bundle.main.infoDictionary?["SIGNIN_WITH_FACEBOOK_REDIRECT"] as? String

    public lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.userContentController = WKUserContentController()
        config.applicationNameForUserAgent = "Version/1.0.0 SygicWebView/1.0.0"
        let webView = WKWebView(frame: view.bounds, configuration: config)
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        return webView
    }()

    private var googleUserAgent: String {
        let osVersion = UIDevice.current.systemVersion
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(osVersion) like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Mobile/14F89 Safari/602.1"
    }

    public let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        return indicator
    }()

    public required init(auth: B2cClientAuth.Policy = .signIn) {
        super.init(nibName: nil, bundle: nil)
        authPolicy = auth
        originalPolicy = auth
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        setupLayout()
        if ReachabilityManager.shared.status == .unreachable {
            showErrorView(for: .noInternet)
        } else {
            refreshWebView()
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.setNavigationBarHidden(!shouldShowNavigationBar, animated: true)
        super.viewWillAppear(animated)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        webView.stopLoading()
        super.viewWillDisappear(animated)
    }

    open func refreshWebView() {
        guard let b2cAuth = Auth.shared.clientAuth as? B2cClientAuth else { return }
        webView.load(b2cAuth.authorizationRequest(for: originalPolicy, signInType: signInDomain))
    }

    private func setupLayout() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        var constraints = [NSLayoutConstraint]()
        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        constraints.append(webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        constraints.append(webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        constraints.append(webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    open func authorizationSuccessfull() {
        print("override me please")
    }

    open func removeAccountSuccessful() {
        print("override me please")
    }

    open func continueWithNativeSignInWithApple() {
        print("override me please")
    }

    open func continueWithNativeSignInFacebook() {
        print("override me please")
    }

    public func showErrorView(for style: MessageViewModel.MessageViewModelStyle) {
        webView.isHidden = true
        activityIndicator.stopAnimating()
        let messageViewModel = MessageViewModel.viewModel(with: style)
        presentErrorView(with: messageViewModel, in: self.view)
    }

    private func updatePolicyIfNeeded(urlQueryItems items: [URLQueryItem]?) {
        guard let queryItems = items else { return }
        if let urlPolicy = queryItems.first(where: {$0.name == "p"})?.value,
           let policy = B2cClientAuth.Policy(with: urlPolicy) {
            if authPolicy != policy {
                authPolicy = policy
            }
        }
    }

    private func updateUserAgentIfNeeded(url: URL, for webView: WKWebView) {
        if let host = url.host, host.contains("google") {
            webView.customUserAgent = googleUserAgent
        }
    }

    open func confirmSignInWithSocialNetwork(wiht jwt: String) {
        guard let b2cAuth = Auth.shared.clientAuth as? B2cClientAuth else { return }
        webView.load(b2cAuth.authorizationRequest(for: B2cClientAuth.Policy.socialLogin(jwt), signInType: nil))
    }

    /// This method can be subclassed in order to do whatever it needs with the authorizaiton code
    /// This base class will look up for the code and asl the authClient to fetch the bearer
    /// - Parameter queryItems: queryItems
    open func processAuthorizationCode(_ authorizationCode: String) {
            guard let b2cAuth = Auth.shared.clientAuth as? B2cClientAuth else { return }
        b2cAuth.requestBearerToken(with: authorizationCode, for: authPolicy) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.authorizationSuccessfull()
                } else {
                    let errorMessage = error?.localizedDescription ?? ""
                    print("login failed \(errorMessage)")
                    if ADASDebug.enabled {
                        self?.showErrorView(for: .custom(title: "AuthToken error", message: errorMessage, icon: MessageViewModel.errorImage))
                    } else {
                        self?.showErrorView(for: .error)
                    }
                }
            }
        }
    }
    
}

// MARK: WKNavigationDelegate

extension AuthPolicyWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        let errorMock = "com.onmicrosoft.triglav.drajv://oauth/redirect?error=server_error&error_description=AADB2C90047%3a+The+resource+%27https%3a%2f%2fztcasinp01euwsadrvtest01.blob.core.windows.net%2factivedirectoryb2c-tst-01%2fsignin_providers_selection.html%27+contains+script+errors+preventing+it+from+being+loaded.%0d%0aCorrelation+ID%3a+b9f49159-34f0-4567-99bb-267fdf0c4f6e%0d%0aTimestamp%3a+2020-07-14+09%3a14%3a51Z%0d%0a"
//        guard let url = URL(string: errorMock) else { return }
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        if ADASDebug.enabled {
            print("WebView shows URL: \(url.absoluteString)")
        }
        if navigationAction.navigationType == .linkActivated,
            navigationAction.targetFrame != navigationAction.sourceFrame {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.allow)
            return
        }
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems
        updatePolicyIfNeeded(urlQueryItems: queryItems)
        updateUserAgentIfNeeded(url: url, for: webView)

        let urlPath = url.absoluteString
        if let signInWithApple = self.signInWithAppleRedirect, urlPath.contains(signInWithApple) {
            decisionHandler(.cancel)
            continueWithNativeSignInWithApple()
            return
        } else if let singInWithFacebook = self.signInWithFacebookRedirect, urlPath.contains(singInWithFacebook) {
            decisionHandler(.cancel)
            continueWithNativeSignInFacebook()
            return
        }
        if url.path.contains("redirect") {
            if url.scheme?.contains("removed-account") ?? false {
                decisionHandler(.cancel)
                removeAccountSuccessful()
                return
            }
            if let authorizationCode = queryItems?.first(where: { $0.name == "code"})?.value {
                processAuthorizationCode(authorizationCode)
            } else if let errorValue = queryItems?.first(where: { $0.name == "error"})?.value {
                print("WEB AUTH error: \(queryItems ?? [])")
                if ADASDebug.enabled {
                    let errorDescription = queryItems?.first(where: { $0.name == "error_description"})?.value
                    showErrorView(for: .custom(title: errorValue, message: errorDescription ?? "", icon: MessageViewModel.errorImage))
                } else {
                    showErrorView(for: .error)
                }
            }
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
