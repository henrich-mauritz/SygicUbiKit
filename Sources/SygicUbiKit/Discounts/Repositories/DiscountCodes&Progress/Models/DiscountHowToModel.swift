import Foundation

// MARK: - DiscountHowToData

public class DiscountHowToData: Codable {
    struct ContainerData: Codable {
        struct Terms: Codable, DiscountTerms {
            var title: String
            var description: String
        }

        var title: String
        var terms: [Terms]
    }

    var data: ContainerData
}

// MARK: DiscountHowToDataProtocol

extension DiscountHowToData: DiscountHowToDataProtocol {
    public var title: String { data.title }
    public var items: [DiscountTerms] { data.terms }
}
