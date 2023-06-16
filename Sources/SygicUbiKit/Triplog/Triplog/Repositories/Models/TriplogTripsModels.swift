import Foundation

// MARK: - NetworkTripsData

struct NetworkTripsData: Codable {
    struct ContainerData: Codable {
        struct TripsData: Codable {
            var page: Int
            var pageSize: Int
            var pagesCount: Int
            var totalItemsCount: Int
            var items: [NetworkTripMonthData]
        }

        var trips: TripsData
    }

    var data: ContainerData
}

// MARK: TriplogTripsDataType

extension NetworkTripsData: TriplogTripsDataType {
    var trips: [TriplogTripDataType] {
        data.trips.items
    }
}

// MARK: - NetworkTripMonthData

public struct NetworkTripMonthData: Codable, TriplogTripDataType {
    public var id: String
    public var status: String
    public var startLocation: NetworkLocation
    public var endLocation: NetworkLocation
    public var startTime: Date
    public var endTime: Date
    public var totalScore: Double?
    public var distanceKm: Double
    public var imageUri: String?
    public var locationStartName: String { startLocation.fullAddress }
    public var locationEndName: String { endLocation.fullAddress }
    public var overallScore: Double? { totalScore }
}

// MARK: - NetworkLocation

public struct NetworkLocation: Codable {
    public var fullAddress: String
    public init(with address: String) {
        fullAddress = address
    }
}
