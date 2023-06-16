import Foundation

// MARK: - NewInfoListItemProtocol

public protocol NewInfoListItemProtocol {
    func update(with viewModel: InfoItemType)
}

// MARK: - InfoItemType

public protocol InfoItemType {
    var title: String { get }
    var subtitle: String? { get }
    var description: String? { get }
    var imageUri: String { get }
    var imageDarkUri: String? { get }
}
