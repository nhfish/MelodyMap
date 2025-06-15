import SwiftUI

struct StarButton: View {
    @State private var isStarred = false

    var body: some View {
        Button(action: { isStarred.toggle() }) {
            Image(systemName: isStarred ? "star.fill" : "star")
                .foregroundColor(.yellow)
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
    }
}

struct StarButton_Previews: PreviewProvider {
    static var previews: some View {
        StarButton()
    }
}
