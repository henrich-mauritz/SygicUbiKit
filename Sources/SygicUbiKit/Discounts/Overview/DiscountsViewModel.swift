import Foundation
import UIKit

// MARK: - DiscountsViewModel

public class DiscountsViewModel: DiscountsViewModelType {
    public weak var delegate: DiscountsViewModelDelegate?
    public var state: DiscountsState = .initial
    public var claimedDiscount: DiscountClaimedViewModelType?
    private var notificationsObservers = [NSObjectProtocol]()
    private lazy var vehicleRepository: VehicleProfileRepositoryType = container.resolveVehicleProfileRepo()
    lazy var repository: DiscountsOverviewRepositoryType = container.resolveDiscountOverviewRepo()

    public var challengeViewModel: DiscountChallengeViewModelProtocol? {
        guard let challenge = data?.currentChallenge else { return nil }
        return ChallengeViewModel(model: challenge)
    }

    public var claimableDiscount: DiscountClaimable? {
        ClaimableDiscount(amount: data?.currentDiscount.discountAmount ?? 0, claimable: data?.currentDiscount.isClaimable ?? false)
    }

    public var infoDetails: [(icon: UIImage?, title: String)] {
        let formatInfo = "discounts.howToDiscount".localized
        return [
            (icon: UIImage(named: "info", in: .module, compatibleWith: nil),
             title: "discounts.yourCodes".localized),
            (icon: UIImage(named: "graph", in: .module, compatibleWith: nil),
             title: "discounts.monthlyProgress".localized),
            (icon: UIImage(named: "discount", in: .module, compatibleWith: nil),
             title: String(format: formatInfo, data?.totalAchievableDiscount ?? 0)),
        ]
    }

    public var maxDiscountAvailable: Bool {
        guard let data = data, let current = data.currentDiscount.discountAmount, claimedDiscount == nil else { return false }
        return current >= data.totalAchievableDiscount
    }

    private var data: DiscountsOverviewProtocol? {
        didSet {
            guard let data = data else { return }
            updateClaimedDiscount(data.currentDiscount)
            updateState()
            delegate?.viewModelUpdated(self)
        }
    }

    private var _currentFilteringVehicle: VehicleProfileType?
    public var currentFilteringVehicle: VehicleProfileType? {
        get {
            if _currentFilteringVehicle != nil {
                return _currentFilteringVehicle
            }
            let storedVehicles = vehicleRepository.storedVehicles
            if storedVehicles.count > 0 {
                let selected = storedVehicles.first { $0.isSelectedForDriving == true }
                _currentFilteringVehicle = selected
            }
            return _currentFilteringVehicle
        }
        set {
            _currentFilteringVehicle = newValue
        }
    }

    public var hasMoreThanOneVehicle: Bool {
        vehicleRepository.activeVehicles.count > 1
    }

    //MARK: - LifeCycle

    public init() {
        injectRepository()
        observeNetworkChange()
    }

    deinit {
        notificationsObservers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }

    // MARK: - Repo Comunication

    public func reloadData(completion: @escaping ((_ finished: Bool) -> Void)) {
        guard let vehicleId = currentFilteringVehicle?.publicId else {
            completion(false)
            return
        }
        delegate?.viewModelDidBegingUpdating()
        repository.loadDiscounts(for: vehicleId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(rewardsData):
                self.data = rewardsData
            case let .failure(error):
                self.delegate?.viewModelDidFail(with: error)
            }
            completion(true)
        }
    }

    public func claimDiscount(completion: @escaping ((_ finished: Bool) -> Void)) {
        guard let vehicleId = currentFilteringVehicle?.publicId else {
            completion(false)
            return
        }
        repository.claimDiscounts(for: vehicleId) {[weak self] result in
            guard let weakSelf = self else { return }
            switch result {
            case let .success(claimedData):
                weakSelf.updateClaimedDiscount(claimedData)
                if weakSelf.claimedDiscount != nil {
                    weakSelf.state = .claimed
                }
                completion(true)
            case let .failure(error):
                guard case NetworkError.httpError(code: _, userInfo: let userInfo) = error, let dict = userInfo?["data"] as? [String: AnyObject],
                    let errorTypeString = dict["reason"] as? String else { return }
                let errorType = DiscountError(rawValue: errorTypeString) ?? .unknown
                weakSelf.delegate?.viewModelError(errorType.localized(), error: errorType)
                completion(false)
            }
        }
    }

    //MARK: - Utils

    private func updateState() {
        guard let data = data else { return }
        if claimedDiscount != nil {
            state = .claimed
        } else {
            if let challengeType = data.currentChallenge?.type, challengeType == .monthly {
                state = .progress
            } else {
                state = .initial
            }
        }
    }

    private func updateClaimedDiscount(_ currentDiscount: DiscountProtocol) {
        if let amount = currentDiscount.discountAmount,
           let code = currentDiscount.discountCode,
           let valid = currentDiscount.validUntil {
            claimedDiscount = ClaimedDiscount(amount: amount, code: code, valid: valid)
        } else {
            claimedDiscount = nil
        }
    }
}

//MARK: - Rechability

extension DiscountsViewModel {
    func observeNetworkChange() {
        notificationsObservers.append(NotificationCenter.default.addObserver(forName: .flagsChanged,
                                                                             object: nil,
                                                                             queue: nil) {[weak self] _ in
                                                DispatchQueue.main.async {
                                                    switch ReachabilityManager.shared.status {
                                                    case .wwan, .wifi:
                                                        self?.reloadData(completion: { _ in })
                                                    default:
                                                        print("no connection reached")
                                                    }
                                                }
        })
    }
}

// MARK: InjectableType

//MARK: - InjectableType

extension DiscountsViewModel: InjectableType {
    fileprivate func injectRepository() {
        container.injectOverviewDiscountRepo()
        container.injectDiscountCodeRepository()
    }
}
