import Foundation

//MARK: - TriplogTripCardViewModel

public class TriplogTripCardViewModel: TriplogTripCardViewModelProtocol {
    public var normalizedDate: Date? {
        return self.data?.endTime.normalizedDate()
    }

    public var dateText: String {
        guard let startDate = data?.startTime,
              let endDate = data?.endTime else { return "" }

        return "\(startDate.hourInDayFormat())–\(endDate.hourInDayFormat())"
    }

    public var scoreText: String {
        guard let score = data?.overallScore else { return "" }
        return Format.scoreFormatted(value: score)
    }

    public var destinationText: String {
        data?.locationEndName ?? ""
    }

    public var descriptionText: String {
        "\(NumberFormatter().distanceTraveledFormatted(value: data?.distanceKm ?? 0)) km"
    }

    public var imageUrl: String? {
        data?.imageUri
    }

    public var data: TriplogTripDataType?
}
