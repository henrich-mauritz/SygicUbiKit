import Foundation
import KeychainAccess

// MARK: - AuthTokenDataType

protocol AuthTokenDataType {
    var userId: String? { get }
    var secureUserId: String? { get }
    var authToken: String { get }
    var authTokenNoType: String { get }
    var isFresh: Bool { get }
    var isValid: Bool { get }
}

extension AuthTokenDataType where Self: Codable {
    static func cleanKeychain() {
        guard let userId = UserDefaults.standard.string(forKey: userIdStoreKey) else { return }
        let keychain = Keychain(service: keychainServiceName(for: userId))
        UserDefaults.standard.removeObject(forKey: userIdStoreKey)
        UserDefaults.standard.synchronize()
        do {
            try keychain.removeAll()
        } catch {
            print(error)
        }
    }

    static func storedData() -> Self? {
        guard let userId = UserDefaults.standard.string(forKey: userIdStoreKey) else { return nil }
        let keychain = Keychain(service: keychainServiceName(for: userId))
        let decoder = JSONDecoder()
        do {
            guard let encodedData = try keychain.getData(authTokenDataServiceKey) else { return nil }
            let authData = try decoder.decode(Self.self, from: encodedData)
            guard authData.isValid else {
                cleanKeychain()
                return nil
            }
            if userIdStoreKey == oldUserIdStoreKey {
                cleanKeychain()
                authData.storeToKeychain()
            }
            return authData
        } catch {
            print(error)
        }
        cleanKeychain()
        return nil
    }

    func storeToKeychain() {
        guard isValid, let userId = userId else { return }
        UserDefaults.standard.set(userId, forKey: Self.userIdStoreKey)
        UserDefaults.standard.synchronize() //TODO: this method is unnecessary and should not be used! RTFM!

        let keychain = Keychain(service: Self.keychainServiceName(for: userId))
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(self)
            try keychain.set(encodedData, key: Self.authTokenDataServiceKey)
        } catch {
            print(error)
        }
    }
}

//TODO: co je toto preboha? pod aky kluc mam ukladat ked robim novy service? Chyba tu vysvetlujuci komentar.
private extension AuthTokenDataType {
    static var oldUserIdStoreKey: String { "si.triglav.userIdStoreKey" }
    static var oldAuthTokenKeychainService: String { "si.triglav.keychainAuthService" }
    static var oldAuthTokenDataServiceKey: String { "si.triglav.authTokenDataKey" }

    static var userIdStoreKey: String {
        if UserDefaults.standard.string(forKey: oldUserIdStoreKey) != nil {
            return oldUserIdStoreKey
        }
        return "\(appBundleId).userIdStoreKey"
    }

    static var authTokenKeychainService: String {
        if UserDefaults.standard.string(forKey: oldUserIdStoreKey) != nil {
            return oldAuthTokenKeychainService
        }
        return "\(appBundleId).keychainAuthService"
    }

    static var authTokenDataServiceKey: String {
        if UserDefaults.standard.string(forKey: oldUserIdStoreKey) != nil {
            return oldAuthTokenDataServiceKey
        }
        return "\(appBundleId).authTokenDataKey"
    }

    static var appBundleId: String { Bundle.main.bundleIdentifier ?? "com.sygic.adasModules" }

    static func keychainServiceName(for userId: String) -> String {
        "\(authTokenKeychainService).\(userId)"
    }
}
