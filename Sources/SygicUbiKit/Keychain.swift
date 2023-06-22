import Foundation

    public class Keychain: NSObject {
    /**
     Function to store a keychain item
     - parameters:
     - value: Value to store in keychain in `data` format
     - account: Account name for keychain item
     */
        public static func set(value: Data, account: String, service: String) throws {
        // If the value exists `update the value`
        if try KeychainOperations.exists(account: account, service: service) {
            try KeychainOperations.update(value: value, account: account, service: service)
        } else {
            // Just insert
            try KeychainOperations.add(value: value, account: account, service: service)
        }
    }
    /**
     Function to retrieve an item in ´Data´ format (If not present, returns nil)
     - parameters:
     - account: Account name for keychain item
     - returns: Data from stored item
     */
        public static func get(account: String, service: String) throws -> Data? {
        if try KeychainOperations.exists(account: account, service: service) {
            return try KeychainOperations.retreive(account: account, service: service)
        } else {
            throw Errors.operationError
        }
    }
    /**
     Function to delete a single item
     - parameters:
     - account: Account name for keychain item
     */
        public static func delete(account: String, service: String) throws {
        if try KeychainOperations.exists(account: account, service: service) {
            return try KeychainOperations.delete(account: account, service: service)
        } else {
            throw Errors.operationError
        }
    }
    /**
     Function to delete all items
     */
        public static func deleteAll(service: String) throws {
            try KeychainOperations.deleteAll(service: service)
    }
}

internal class KeychainOperations: NSObject {
    /**
     Funtion to add an item to keychain
     - parameters:
     - value: Value to save in `data` format (String, Int, Double, Float, etc)
     - account: Account name for keychain item
     */
    internal static func add(value: Data, account: String, service: String) throws {
        let status = SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            // Allow background access:
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData: value,
            ] as NSDictionary, nil)
        guard status == errSecSuccess else { throw Errors.operationError }
    }
    /**
     Function to update an item to keychain
     - parameters:
     - value: Value to replace for
     - account: Account name for keychain item
     */
    internal static func update(value: Data, account: String, service: String) throws {
        let status = SecItemUpdate([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            ] as NSDictionary, [
                kSecValueData: value,
                ] as NSDictionary)
        guard status == errSecSuccess else { throw Errors.operationError }
    }
    /**
     Function to retrieve an item to keychain
     - parameters:
     - account: Account name for keychain item
     */
    internal static func retreive(account: String, service: String) throws -> Data? {
        /// Result of getting the item
        var result: AnyObject?
        /// Status for the query
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            kSecReturnData: true,
            ] as NSDictionary, &result)
        // Switch to conditioning statement
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw Errors.operationError
        }
    }
    /**
     Function to delete a single item
     - parameters:
     - account: Account name for keychain item
     */
    internal static func delete(account: String, service: String) throws {
        /// Status for the query
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            ] as NSDictionary)
        guard status == errSecSuccess else { throw Errors.operationError }
    }
    /**
     Function to delete all items for the app
     */
    internal static func deleteAll(service: String) throws {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrServer: service,
            ] as NSDictionary)
        guard status == errSecSuccess else { throw Errors.operationError }
    }
    /**
     Function to check if we've an existing a keychain `item`
     - parameters:
     - account: String type with the name of the item to check
     - returns: Boolean type with the answer if the keychain item exists
     */
    static func exists(account: String, service: String) throws -> Bool {
        /// Constant with current status about the keychain to check
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            kSecReturnData: false,
            ] as NSDictionary, nil)
        // Switch to conditioning statement
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw Errors.creatingError
        }
    }
}

//internal let service: String = "Device"

/**
 Private enum to return possible errors
 */
internal enum Errors: Error {
    /// Error with the keychain creting and checking
    case creatingError
    /// Error for operation
    case operationError
}
