import Foundation

// MARK: - DiscountCodesRepositoryType

public protocol DiscountCodesRepositoryType {
    func loadDiscountCodeData(for vehicleId: String, completion: @escaping (Result<DiscountCodesDataProtocol, Error>) -> ())
    func loadMoreDiscountCodeData(for page: Int, with vehicleId: String, completion: @escaping (Result<DiscountCodesDataProtocol, Error>) -> ())
    func loadHowToData(for type: VehicleType, completion: @escaping (Result<DiscountHowToDataProtocol, Error>) -> ())
    func loadProgressData(for vehicleId: String, _ completion: @escaping (Result<DiscountProgressDataProtocol, Error>) -> ())
}

// MARK: - DiscountCodesNewtorkRepositoryType

protocol DiscountCodesNewtorkRepositoryType: DiscountCodesRepositoryType {}
