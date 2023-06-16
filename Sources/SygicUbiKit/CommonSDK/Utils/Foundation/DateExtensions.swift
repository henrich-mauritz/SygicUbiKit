import Foundation

public extension Date {
    static func maxDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        guard let date = formatter.date(from: "9999-12-31T23:59:59.999+00:00") else {
            fatalError("This shouldn't happen here, please check the date format of max date")
        }
        return date
    }

    var currentMonthNumber: Int {
        let dateComponents = Calendar.current.dateComponents([.month], from: self)
        return dateComponents.month ?? 1
    }

     var currentMonthName: String {
         let formatter = DateFormatter()
         if let preferredLanguage = CommonConfigurator.shared.configuration.preferredLanguage {
             formatter.locale = Locale(identifier: preferredLanguage)
         }
         formatter.dateFormat = "MMMM"
         return formatter.string(from: self)
    }

    func hourInDayFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        let dateString = formatter.string(from: self)
        return dateString
    }

    func dayAndMonthFormat() -> String {
        let formatter = DateFormatter()
        if let preferredLanguage = CommonConfigurator.shared.configuration.preferredLanguage {
            formatter.locale = Locale(identifier: preferredLanguage)
        }
        formatter.dateFormat = "dd"
        let day = formatter.string(from: self)
        formatter.dateFormat = "MMM"
        let month = formatter.string(from: self)
        return "\(day) \(month)"
    }

    func monthFormatter() -> String {
        let formatter = DateFormatter()
        if let preferredLanguage = CommonConfigurator.shared.configuration.preferredLanguage {
            formatter.locale = Locale(identifier: preferredLanguage)
        }
        formatter.dateFormat = "MMM"
        let month = formatter.string(from: self)
        return "\(month)"
    }

    func timeFormatedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    func periodForEndFormatter(end: Date) -> String {
        let calendar = Calendar.current
        let yearStart = calendar.component(.year, from: self)
        let yearEnd = calendar.component(.year, from: end)
        var startFormatted: String
        if yearStart == yearEnd {
            startFormatted = monthFormatter()
        } else {
            startFormatted = monthAndYearFormatter()
        }
        let endFormatted: String = end.monthAndYearFormatter()
        return "\(startFormatted)–\(endFormatted)"
    }

    func monthAndYearFormatter(fullMonthName: Bool = false) -> String {
        let formatter = DateFormatter()
        if let preferredLanguage = CommonConfigurator.shared.configuration.preferredLanguage {
            formatter.locale = Locale(identifier: preferredLanguage)
        }
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: self)
        formatter.dateFormat = fullMonthName == true ? "MMMM" : "MMM"
        let month = formatter.string(from: self)
        return "\(month) \(year)"
    }

    /// Removes from self the hours minutes and seconds, letting a normalized date using current calendar
    func normalizedDate() -> Date {
        let date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)
        if date == nil {
            print("Couldn't normalize the date \(self), returning same date")
        }
        return date ?? self
    }
}
