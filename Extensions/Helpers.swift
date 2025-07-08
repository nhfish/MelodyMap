import Foundation
import SwiftUI

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
                    let deletion = distances[i - 1][j] + 1
                    let insertion = distances[i][j - 1] + 1
                    let substitution = distances[i - 1][j - 1] + 1
                    distances[i][j] = Swift.min(deletion, Swift.min(insertion, substitution))
                }
            }
        }

        return distances[lhs.count][rhs.count]
    }
}

@MainActor
class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    private var cancellableShow: Any?
    private var cancellableHide: Any?

    init() {
        cancellableShow = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.isKeyboardVisible = true }
        }
        cancellableHide = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.isKeyboardVisible = false }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#if canImport(UIKit)
import UIKit
import SwiftUI

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view?.bounds ?? .zero, afterScreenUpdates: true)
        }
    }
}

extension UIView {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
#endif
