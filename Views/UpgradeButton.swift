import SwiftUI

struct UpgradeButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundColor(.yellow)
                .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Upgrade")
    }
}

struct UpgradeButton_Previews: PreviewProvider {
    static var previews: some View {
        UpgradeButton(action: {})
    }
} 