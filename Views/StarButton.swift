import SwiftUI

struct StarButton: View {
    @Binding var isStarred: Bool

    var body: some View {
        Button(action: {
            isStarred.toggle()
        }) {
            Image(systemName: isStarred ? "star.fill" : "star")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(.appAccent)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(isStarred ? "Remove from Favorites" : "Add to Favorites")
        .padding(4)
    }
}

struct StarButton_Previews: PreviewProvider {
    static var previews: some View {
        StarButton(isStarred: .constant(true))
    }
}
