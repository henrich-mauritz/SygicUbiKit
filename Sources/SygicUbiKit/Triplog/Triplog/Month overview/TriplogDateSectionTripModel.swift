
import Foundation

// MARK: - TriplogDateSectionTripModelProtocol

public protocol TriplogDateSectionTripModelProtocol {
    var sectionDate: Date { get }
    var sectionTrips: [TriplogTripCardViewModelProtocol] { get }
    var sectionTitle: String { get }
}

// MARK: - TriplogDateSectionTripModel

public struct TriplogDateSectionTripModel: TriplogDateSectionTripModelProtocol {
    public var sectionTrips: [TriplogTripCardViewModelProtocol]
    public var sectionDate: Date
    private let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter
    }()

    public var sectionTitle: String {
        return dateFormatter.string(from: sectionDate)
    }
}
