import Foundation

// MARK: - ChallengeViewModel

struct ChallengeViewModel: DiscountChallengeViewModelProtocol {
    var title: String
    var description: String = ""
    var steps: [DiscountChallengeStepViewModelProtocol]
    private var model: DiscountsChallenge

    init(model: DiscountsChallenge) {
        self.model = model
        var stepsAmount: Double = 0
        var targetValue: Double = 0
        var stepsVM = [DiscountChallengeStepViewModelProtocol]()
        model.steps.forEach { step in
            stepsAmount += step.discountIncrement
            targetValue += step.goalKm
            stepsVM.append(ChallengeStepViewModel(model: step))
        }
        steps = stepsVM
        switch model.type {
        case .starting:
            title = "discounts.initialChallengeTitle".localized
            description = String(format: "discounts.initialChallengeDescription".localized, targetValue, model.overallScoreRequirement, stepsAmount)
        case .monthly:
            let formatter = DateFormatter()
            if let preferredLanguage = CommonConfigurator.shared.configuration.preferredLanguage {
                formatter.locale = Locale(identifier: preferredLanguage)
            }
            formatter.dateFormat = "MMMM"
            title = formatter.string(from: Date()) + " " + "discounts.monthlyChallengeTitle".localized
            description = String(format: "discounts.monthlyChallengeDescriptionOverRequirement".localized, stepsAmount, targetValue, model.overallScoreRequirement)
        }
        if isUnderRequirement() {
            description = String(format: "discounts.monthlyChallengeDescriptionUnderRequirement".localized, model.overallScoreRequirement)
        }
    }

    public func isUnderRequirement() -> Bool {
        model.overallScoreRequirement > model.overallScore
    }
}

// MARK: - ChallengeStepViewModel

struct ChallengeStepViewModel: DiscountChallengeStepViewModelProtocol {
    var stepProgress: Double
    var stepProgressTitle: String
    var stepProgressSubtitle: String?
    var stepTargetAmount: String
    init(model: DiscountsChallengeStep) {
        stepProgress = model.currentKm / model.goalKm
        stepProgressTitle = "\(NumberFormatter().distanceTraveledFormatted(value: model.currentKm))/\(NumberFormatter().distanceTraveledFormatted(value: model.goalKm))"
        stepTargetAmount = String(format: "%.0f %%", model.totalDiscount)
    }
}

// MARK: - ClaimedDiscount

struct ClaimedDiscount: DiscountClaimedViewModelType {
    var claimedTitle: String
    var claimedCode: String
    var claimedValidity: String
    var isValid: Bool
    init(amount: Double, code: String, valid: Date) {
        let formatTitle = "discounts.codeBubble.descriptionPrefix".localized
        claimedTitle = String(format: formatTitle, amount)
        claimedCode = code
        claimedValidity = valid.formatValidityDate()
        isValid = Date().compare(valid) == .orderedAscending
    }
}

// MARK: - ClaimableDiscount

struct ClaimableDiscount: DiscountClaimable {
    var amount: String
    var canBeClaimed: Bool
    init(amount: Double, claimable: Bool) {
        self.amount = String(format: "%.0f %%", amount)
        canBeClaimed = claimable
    }
}
