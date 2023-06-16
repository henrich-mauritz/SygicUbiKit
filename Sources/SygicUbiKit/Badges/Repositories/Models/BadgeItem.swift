import Foundation

// MARK: - BadgeItemType

//MARK: - Badge Item

public protocol BadgeItemType {
    var id: String { get }
    var imageLightUri: String { get }
    var imageDarkUri: String { get }
    var title: String { get }
    var currentLevel: Int { get }
    var maximumLevel: Int { get }
}

public extension BadgeItemType {
    var earned: Bool {
        return currentLevel > 0
    }
}

// MARK: - BadgesListable

public protocol BadgesListable {
    var badges: [BadgeItemType] { get }
}

// MARK: - BadgeImages

public struct BadgeImages: Codable {
    public var lightUri: String
    public var darkUri: String?
}

// MARK: - NetworkBadgesList

public struct NetworkBadgesList: Codable {
     struct Container: Codable {
        struct BadgeItem: Codable, BadgeItemType {
            var id: String
            var image: BadgeImages
            var title: String
            var currentLevel: Int
            var maximumLevel: Int
        }

        var badges: [BadgeItem]
    }

    var data: Container
}

extension NetworkBadgesList.Container.BadgeItem {
    var imageLightUri: String { image.lightUri }
    var imageDarkUri: String { image.darkUri ?? imageLightUri }
}

// MARK: - NetworkBadgesList + BadgesListable

extension NetworkBadgesList: BadgesListable {
    public var badges: [BadgeItemType] {
        return data.badges
    }
}

// MARK: - BadgeItemDetailType

//MARK: - Badge Detail

public protocol BadgeItemDetailType {
    var id: String { get }
    var imageLightUri: String { get }
    var imageDarkUri: String { get }
    var title: String { get }
    var subtitle: String { get }
    var currentLevel: Int { get }
    var maximumLevel: Int { get }
    var progression: BadgeItemProgression { get }
}

// MARK: - NetworkBadgeData

public struct NetworkBadgeData: Codable {
    var data: NetworkBadgeDetail
}

// MARK: - NetworkBadgeDetail

public struct NetworkBadgeDetail: Codable, BadgeItemDetailType {
    public var id: String
    public var image: BadgeImages
    public var title: String
    public var subtitle: String
    public var currentLevel: Int
    public var maximumLevel: Int
    public var progression: BadgeItemProgression
}

public extension NetworkBadgeDetail {
    var imageLightUri: String { image.lightUri }
    var imageDarkUri: String { image.darkUri ?? imageLightUri }
}

// MARK: - BadgeItemProgression

/// Badge Progression
public struct BadgeItemProgression: Codable {
    var title: String
    var description: String
    var current: Int
    var total: Int
}
