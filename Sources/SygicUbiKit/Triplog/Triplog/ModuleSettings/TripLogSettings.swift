
import Foundation

// MARK: - TripLogConfigurable

public protocol TripLogConfigurable {
    var toggalbleLayouts: Bool { get }
    var defaultLayout: TriplogMonthlyListingType { get }
    var eventReportingEnabled: Bool { get }
    var displayDetailCopyrightNotice: Bool { get }
}

extension TripLogConfigurable {
    var eventReportingEnabled: Bool { return true }
}

// MARK: - TripLogSettingsManager

public class TripLogSettingsManager {
    static let shared: TripLogSettingsManager = TripLogSettingsManager()

    public private(set) var currentSettings: TripLogConfigurable

    private init() {
        currentSettings = TripLogSettings()
    }

    /// overriding current default settings
    /// - Parameter settings: settings parameter
    public class func configureWith(settings: TripLogConfigurable) {
        TripLogSettingsManager.shared.currentSettings = settings
    }
}

// MARK: - TripLogSettings

struct TripLogSettings: TripLogConfigurable {
    var displayDetailCopyrightNotice: Bool = true
    var toggalbleLayouts: Bool = false
    var defaultLayout: TriplogMonthlyListingType = .list
}
