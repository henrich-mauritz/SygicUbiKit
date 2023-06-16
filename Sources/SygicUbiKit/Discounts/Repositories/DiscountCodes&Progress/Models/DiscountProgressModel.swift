import Foundation

// MARK: - DiscountProgressData

public class DiscountProgressData: Codable {
    struct ContainerData: Codable {
        struct Challange: Codable, DiscountProgressChallange {
            struct Step: Codable, ChallangeSteps {
                var state: DiscountProgressType
                var discountAmount: Double
            }

            var type: DiscountChallengeType
            var startInclusive: Date
            var endExclusive: Date?
            var steps: [Step]
            var items: [ChallangeSteps]? { steps }
            var date: Date? { startInclusive }
        }

        var challenges: [Challange]
    }

    var data: ContainerData
}

// MARK: DiscountProgressDataProtocol

extension DiscountProgressData: DiscountProgressDataProtocol {
    public var items: [DiscountProgressChallange] { data.challenges }
}
