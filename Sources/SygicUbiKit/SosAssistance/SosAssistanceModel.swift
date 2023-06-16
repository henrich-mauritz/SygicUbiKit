import Foundation
import UIKit

public struct SosAssistanceModel: SosAssistanceModelProtocol {
    public struct Contact: ContactData {
        public var title: String
        public var subtitle: String?
        public var icon: UIImage?
        public var phoneNumber: String
        public var highlighted: Bool
        public init(title: String, subtitle: String?, icon: UIImage?, number: String, highlighted: Bool) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.phoneNumber = number
            self.highlighted = highlighted
        }
    }

    public var emergencyContacts: [ContactData]

    public init(emergencyContacts contacts: [Contact]) {
        emergencyContacts = contacts
    }
}
