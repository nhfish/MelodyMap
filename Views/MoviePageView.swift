import SwiftUI

struct MoviePageView: View {
    let movie: Movie

    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: movie.imageURL)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxHeight: 300)

            Text(movie.title)
                .font(.title)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}

struct MoviePageView_Previews: PreviewProvider {
    static var previews: some View {
        MoviePageView(
            movie: Movie(id: "1", title: "Sample Movie", imageURL: "https://example.com/poster.jpg", releaseYear: 2024, sortOrder: 1)
        )
    }
}
