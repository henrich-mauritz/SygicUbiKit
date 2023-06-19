import Foundation

public struct SygicUbiKit {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

extension String {
    var localized: String {
        return Bundle.main.localizedString(forKey: self, value: self, table: nil)
    }
}

public enum AnalyticsKeys {
    static let triplogShown: String = "trip_log_shown"
    static let tripArchiveShown: String = "trip_archive_shown"
    static let monthlyCardShown: String = "monthly_card_shown"
    static let tripDetailShown: String = "trip_detail_shown"
    
    static let drivingScreenShown: String = "driving_screen_shown"
    static let drivingStartButtonSwipe: String = "driving_start_button_swipe"
    static let drivingTripSummaryShow: String = "driving_trip_summary_shown"
    static let drivingTripUploadError: String = "driving_trip_upload_error"
    
    static let discountShown = "discounts_shown"
    static let howToGet25Shown = "how_to_get_25_shown"
    static let monthlyProgressShown = "your_monthly_progress _shown"
    static let discountCodeShown = "your_discount_codes_shown"
    static let discountClaimedTap = "discount_claimed_tap"
    static let discountClaimSuccess = "discount_claimed_successful"
    
    static let dashcamOnboardingShwon = "dashcam_onboarding_shown"
    static let dashcamShown = "dashcam_shown"
    static let dashcamStartRecording = "dashcam_start_recording_tap"
    static let dashcamStopRecording = "dashcam_stop_recording_tap"
    
    static let didShowMonthlyStatsOverview = "monthly_stats_overview_shown"
    static let didShowMonthlyStatMonthSelector = "monthly_stats_month_selector_shown"
    
    static let assistanceShown = "assistance_shown"
    static let assistanceCall = "assistance_call"

    struct Parameters {
        static let phoneNumberKey = "phone_number"
        
        static let monthKey = "month"
        static let yearKey = "year"
        
        public static let tripSumaryKey = "trip_summary"
        public static let errorCodeKey = "error_code"
        public static let errorDescriptionKey = "error_description"
        public static let networkTypeKey = "network_type"
        public static let scoreValue = "trip_score"
        public static let tripDistanceTooShortValue = "trip_distance_too_short"
        public static let tripDurationTooShortValue = "trip_duration_too_short"
        public static let timeoutValue = "timeout"
        public static let offilineValue = "offline"
        public static let fraudBehaviourValue = "fraud_behaviour"
        public static let invalidSystemTimeValue = "invalid_system_time"
        public static let generalErrorValue = "general_error"
        public static let none = "none"
        public static let uploadFailed = "upload_failed"
        public static let timePeriodProhibited = "time_period_prohibited"
        public static let invalidInput = "invalid_input"
        public static let invalidEvent = "invalid_event"
        public static let unknown = "unknown"
    }
}
