import Foundation

// Add general helper extensions here

extension String {
    /// Computes the Levenshtein distance between this string and the given string.
    /// - Parameter other: The string to compare against.
    /// - Returns: The number of single-character edits required to transform this string into `other`.
    func levenshteinDistance(to other: String) -> Int {
        let lhs = Array(self)
        let rhs = Array(other)

        if lhs.isEmpty { return rhs.count }
        if rhs.isEmpty { return lhs.count }

        var distances = Array(repeating: Array(repeating: 0, count: rhs.count + 1), count: lhs.count + 1)

        for i in 0...lhs.count { distances[i][0] = i }
        for j in 0...rhs.count { distances[0][j] = j }

        for i in 1...lhs.count {
            for j in 1...rhs.count {
                if lhs[i - 1] == rhs[j - 1] {
                    distances[i][j] = distances[i - 1][j - 1]
                } else {
                    distances[i][j] = min(
                        distances[i - 1][j] + 1,
                        distances[i][j - 1] + 1,
                        distances[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return distances[lhs.count][rhs.count]
    }
}
