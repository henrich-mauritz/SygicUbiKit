import SygicMaps

// MARK: - SYOnlineSessionPrivate
//TODO: Toto je co za opicarina?! komplet cely subor!
/*
@objc
protocol SYOnlineSessionPrivate {
    var accessToken: String? { get }
    var isAuthenticatedWithAccount: NSNumber? { get }

    func overrideSSOServerUrl(_ ssoServer: NSURL, productServerUrl productServer: NSURL)
    func authenticate(withFacebookToken token: String)
    func authenticate(withGoogleToken token: String)
    func authenticate(withAppleToken token: String)
    func authenticate(withSygicAccount email: String, password: String)
    func authenticateWithoutAccount()
    func resetAuthentication()
}

public extension SYOnlineSession {
    var accessToken: String? {
        (SYOnlineSession.shared() as AnyObject).accessToken
    }

    var isAuthenticatedWithAccount: Bool {
        let privateIdentifier = #selector(getter: SYOnlineSessionPrivate.isAuthenticatedWithAccount)
        let isAuthenticatedWithAccount = SYOnlineSession.shared().perform(privateIdentifier)?.takeUnretainedValue() as? NSNumber
        return isAuthenticatedWithAccount?.boolValue ?? false
    }

    func overrideSSOServerURL(_ ssoServer: NSURL, productServerUrl productServer: NSURL) {
        (SYOnlineSession.shared() as AnyObject).overrideSSOServerUrl(ssoServer, productServerUrl: productServer)
    }

    func authenticate(withFacebookToken token: String) {
        (SYOnlineSession.shared() as AnyObject).authenticate(withFacebookToken: token)
    }

    func authenticate(withGoogleToken token: String) {
        (SYOnlineSession.shared() as AnyObject).authenticate(withGoogleToken: token)
    }

    func authenticate(withAppleToken token: String) {
        (SYOnlineSession.shared() as AnyObject).authenticate(withAppleToken: token)
    }

    func authenticate(withSygicAccount email: String, password: String) {
        (SYOnlineSession.shared() as AnyObject).authenticate(withSygicAccount: email, password: password)
    }

    func authenticateWithoutAccount() {
        let privateIdentifier = #selector(SYOnlineSessionPrivate.authenticateWithoutAccount)
        SYOnlineSession.shared().perform(privateIdentifier)
    }

    func resetAuthentication() {
        (SYOnlineSession.shared() as AnyObject).resetAuthentication()
    }
}
*/
