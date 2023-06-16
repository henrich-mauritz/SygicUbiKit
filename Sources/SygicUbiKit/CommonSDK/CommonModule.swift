import Foundation
import UIKit

public extension Bundle {
    static var displayName: String? {
        guard let dictionary = Bundle.main.infoDictionary else {
            return nil
        }
        if let appName: String = dictionary["CFBundleDisplayName"] as? String {
            return appName
        } else {
            return nil
        }
    }

    static var companyName: String? {
        guard let dictionary = Bundle.main.infoDictionary else {
            return nil
        }
        if let cName: String = dictionary["COMPANY_NAME"] as? String {
            return cName
        } else {
            return nil
        }
    }
}
