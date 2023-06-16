import Foundation

class TriplogOverviewCacheRepository: TriplogOverviewCacheRepositoryType {
    var data: TriplogOverviewDataType?
    var archiveData: [String: TriplogOverviewDataType]? = [:]

    public func cardOverviewModel(for data: TriplogOverviewCardDataType) -> TriplogOverviewCardDataType? {
        var cardData: TriplogOverviewCardDataType?

        if let currentData = self.data {
            for currentCardData in currentData.cards {
                if data.cardId == currentCardData.cardId {
                    cardData = currentCardData
                    break
                }
            }
        }

        if let _ = cardData {
            return cardData
        }

        guard let archiveData = self.archiveData else {
            return nil
        }

        for (_, val) in archiveData.enumerated() {
            let filetered = val.value.cards.filter {
                $0.cardId == data.cardId
            }
            if !filetered.isEmpty {
                cardData = filetered.first
                break
            }
        }

        return cardData
    }

    func archivedData(with id: String) -> TriplogOverviewDataType? {
        return archiveData?[id]
    }

    public func purgueData() {
        data = nil
        archiveData = [:]
    }
}
