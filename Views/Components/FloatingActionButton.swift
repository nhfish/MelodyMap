import SwiftUI

struct FloatingActionButton: View {
    let systemName: String
    let color: Color
    let action: () -> Void
    let accessibilityLabel: String
    var size: CGFloat = 36

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(color)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(accessibilityLabel)
        .padding(8)
    }
} 