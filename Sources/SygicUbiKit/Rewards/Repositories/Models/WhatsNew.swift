import Foundation

// MARK: - NetworkWhatsNewRewardsData

public struct NetworkWhatsNewRewardsData: Codable {
    struct Container: Codable {
        let lastChangeDate: Date
        let isAnyNewContestPending: Bool
        let isAnyNewContestAwarded: Bool
    }

    var data: Container
}

public extension NetworkWhatsNewRewardsData {
    var lastChangeDate: Date { data.lastChangeDate }
    var isAnyNewContestPending: Bool { data.isAnyNewContestPending }
    var isAnyNewContestAwarded: Bool { data.isAnyNewContestAwarded }
}
