import Foundation

// MARK: - TableSectionType

public protocol TableSectionType {
    var title: String { get }
    var numberOfRows: Int { get }
    func removeRows(at indexes: [Int])
}

public extension TableSectionType {
    func removeRows(at indexes: [Int]) {}
}
