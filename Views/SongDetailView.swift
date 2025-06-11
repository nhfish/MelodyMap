import SwiftUI

struct SongDetailView: View {
    var song: Song

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(song.title)
                .font(.title)
            Text("From \(song.movieTitle)")
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
        SongDetailView(song: Song(movieTitle: "Sample", title: "Sample", singers: [], startTime: 0, releaseYear: 2024, runtime: 0, streamingLinks: [], purchaseLinks: [], keywords: [], blurb: "Sample"))
    }
}
