import Foundation

class DiscountCodesProgressRepository: DiscountCodesRepositoryType {
    private let networkRepo: DiscountCodesNewtorkRepositoryType

    init(with networkRepository: DiscountCodesNewtorkRepositoryType) {
        networkRepo = networkRepository
    }

    func loadDiscountCodeData(for vehicleId: String, completion: @escaping (Result<DiscountCodesDataProtocol, Error>) -> ()) {
        networkRepo.loadDiscountCodeData(for: vehicleId, completion: completion)
    }

    func loadMoreDiscountCodeData(for page: Int, with vehicleId: String, completion: @escaping (Result<DiscountCodesDataProtocol, Error>) -> ()) {
        networkRepo.loadMoreDiscountCodeData(for: page, with: vehicleId, completion: completion)
    }

    func loadHowToData(for type: VehicleType, completion: @escaping (Result<DiscountHowToDataProtocol, Error>) -> ()) {
        networkRepo.loadHowToData(for: type, completion: completion)
    }

    func loadProgressData(for vehicleId: String, _ completion: @escaping (Result<DiscountProgressDataProtocol, Error>) -> ()) {
        networkRepo.loadProgressData(for: vehicleId, completion)
    }
}
