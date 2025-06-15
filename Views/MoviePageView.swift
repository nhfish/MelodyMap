import SwiftUI

struct MoviePageView: View {
    let movie: Movie
    let songs: [Song]

    private var songsForMovie: [Song] {
        songs.filter { $0.movieId == movie.id }
    }

    var body: some View {
        ScrollViewReader { proxy in
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
                .frame(height: 200)

                GeometryReader { geo in
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.secondary)
                        ForEach(songsForMovie) { song in
                            Circle()
                                .frame(width: 12, height: 12)
                                .position(x: geo.size.width * CGFloat(song.percent) / 100,
                                          y: 1)
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                let ratio = min(max(0, value.location.x / geo.size.width), 1)
                                let nearest = songsForMovie.min {
                                    abs(ratio - CGFloat($0.percent) / 100) <
                                    abs(ratio - CGFloat($1.percent) / 100)
                                }
                                if let nearest = nearest {
                                    withAnimation {
                                        proxy.scrollTo(nearest.id, anchor: .top)
                                    }
                                }
                            }
                    )
                }
                .frame(height: 12)

                Text(movie.title)
                    .font(.title2)
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(songsForMovie) { song in
                            Text(song.title)
                                .id(song.id)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
        }
    }
}

struct MoviePageView_Previews: PreviewProvider {
    static var previews: some View {
        MoviePageView(
            movie: Movie(id: "1", title: "Sample Movie", imageURL: "https://example.com/poster.jpg", releaseYear: 2024, sortOrder: 1),
            songs: [
                Song(id: "song1", movieId: "1", title: "First", percent: 10, startTime: "00:01:00", singers: [], releaseYear: 2024, movieRuntimeMinutes: 90, streamingLinks: [], purchaseLinks: [], keywords: [], blurb: "")
            ]
        )
    }
}
