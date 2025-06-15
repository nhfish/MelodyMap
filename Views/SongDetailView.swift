import SwiftUI

struct SongDetailView: View {
    var song: Song

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(song.title)
                .font(.title)
            Text("From \(song.movieId)")
                .font(.subheadline)
            Text(song.blurb)
            Spacer()
        }
        .padding()
        .navigationTitle(song.title)
    }
}

struct SongDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SongDetailView(song: Song(id: "song1", movieId: "movie1", title: "Sample", percent: 50, startTime: "00:00:30", singers: [], releaseYear: 2024, movieRuntimeMinutes: 90, streamingLinks: [], purchaseLinks: [], keywords: [], blurb: "Sample"))
    }
}
