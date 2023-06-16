
import Foundation

public extension Array {
    /// Mutate an array of struct on a given element at index
    /// - Parameters:
    ///   - index: index of the element to modify
    ///   - modifyElement: the elemen to modify upon compleiton
    /// - Returns: void
    mutating func modifyElement(atIndex index: Index, _ modifyElement: (_ element: inout Element) -> ()) {
        var element = self[index]
        modifyElement(&element)
        self[index] = element
    }
}
