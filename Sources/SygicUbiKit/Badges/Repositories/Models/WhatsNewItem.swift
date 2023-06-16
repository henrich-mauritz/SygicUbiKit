import Foundation

// MARK: - NetworkWhatsNewBadgeData

public struct NetworkWhatsNewBadgeData: Codable {
    struct Container: Codable {
        let lastChangeDate: Date
        let isAnyNewBadgeLevelUnlocked: Bool
    }

    var data: Container
}

extension NetworkWhatsNewBadgeData {
    var lastChangeDate: Date { return data.lastChangeDate }
    var isAnyNewBadgeLevelUnlocked: Bool { return data.isAnyNewBadgeLevelUnlocked }
}
