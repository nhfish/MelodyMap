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
                .frame(width: 44, height: 44)
                .foregroundColor(.yellow)
                .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(isStarred ? "Remove from Favorites" : "Add to Favorites")
        .padding(8)
    }
}

struct StarButton_Previews: PreviewProvider {
    static var previews: some View {
        StarButton(isStarred: .constant(true))
    }
}
