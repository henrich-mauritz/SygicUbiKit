import Foundation

public extension String {
    func split(every length: Int) -> [Substring] {
        guard length > 0 && length < count else { return [suffix(from: startIndex)] }
        return (0 ... (count - 1) / length).map { dropFirst($0 * length).prefix(length) }
    }

    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex) ..< self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }

}
