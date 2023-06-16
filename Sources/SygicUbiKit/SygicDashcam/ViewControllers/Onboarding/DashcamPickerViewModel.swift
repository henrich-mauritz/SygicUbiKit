import Foundation

// MARK: - DashcamOnboardingPickerType

enum DashcamOnboardingPickerType {
    case duration, quality
}

// MARK: - DashcamOnboardingPickerDelegate

protocol DashcamOnboardingPickerDelegate: AnyObject {
    func didSelect(option: DashcamOption, pickerType: DashcamOnboardingPickerType)
}

// MARK: - DashcamPickerViewModelProtocol

protocol DashcamPickerViewModelProtocol {
    var numberOfItems: Int { get }
    var selectedItemIndex: Int? { get }
    var pickerDelegate: DashcamOnboardingPickerDelegate? { get set }

    func title(for index: Int) -> String
    func didSelect(index: Int)
}

// MARK: - DashcamPickerViewModel

final class DashcamPickerViewModel: DashcamPickerViewModelProtocol {
    weak var pickerDelegate: DashcamOnboardingPickerDelegate?

    private let options: [DashcamOption]
    private let pickerType: DashcamOnboardingPickerType

    private var setting: DashcamOption {
        willSet {
            pickerDelegate?.didSelect(option: newValue, pickerType: pickerType)
        }
    }

    init(with options: [DashcamOption], pickerType: DashcamOnboardingPickerType, selectedOption: DashcamOption) {
        self.options = options
        self.pickerType = pickerType
        self.setting = selectedOption
    }
}

extension DashcamPickerViewModel {
    var numberOfItems: Int {
        options.count
    }

    var selectedItemIndex: Int? {
        options.firstIndex(where: { $0.optionToSave == setting.optionToSave })
    }

    func title(for index: Int) -> String {
        guard options.indices.contains(index) else { return "" }
        return options[index].title
    }

    func didSelect(index: Int) {
        guard options.indices.contains(index) else { return }
        setting = options[index]
    }
}
