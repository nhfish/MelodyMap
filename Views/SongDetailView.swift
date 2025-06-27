import SwiftUI

struct SongDetailView: View {
    var song: Song

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(song.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text("From \(song.movieId)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let blurb = song.blurb, !blurb.isEmpty {
                Text(blurb)
                    .font(.body)
                    .padding(.vertical, 8)
            }
            
            // Streaming and purchase icons
            if !song.streamingLinks.isEmpty || !song.purchaseLinks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Available On")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 20) {
                        // Apple Music
                        let appleMusicURL = (song.streamingLinks + song.purchaseLinks).first(where: { $0.localizedCaseInsensitiveContains("music.apple.com") || $0.localizedCaseInsensitiveContains("apple.com/music") })
                        if let url = appleMusicURL {
                            Link(destination: URL(string: url)!) {
                                Image(systemName: "music.note")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.pink)
                                    .accessibilityLabel("Apple Music")
                            }
                        } else {
                            Image(systemName: "music.note")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                                .accessibilityLabel("Apple Music (Unavailable)")
                        }
                        
                        // Apple Movie Store
                        let appleURL = (song.streamingLinks + song.purchaseLinks).first(where: { $0.localizedCaseInsensitiveContains("itunes") || $0.localizedCaseInsensitiveContains("apple.com/movies") })
                        if let url = appleURL {
                            Link(destination: URL(string: url)!) {
                                Image(systemName: "applelogo")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.primary)
                                    .accessibilityLabel("Apple Movie Store")
                            }
                        } else {
                            Image(systemName: "applelogo")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                                .accessibilityLabel("Apple Movie Store (Unavailable)")
                        }
                        
                        // Disney+
                        let disneyURL = (song.streamingLinks + song.purchaseLinks).first(where: { $0.localizedCaseInsensitiveContains("disney") })
                        if let url = disneyURL {
                            Link(destination: URL(string: url)!) {
                                Image(systemName: "play.rectangle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.blue)
                                    .accessibilityLabel("Disney Plus")
                            }
                        } else {
                            Image(systemName: "play.rectangle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                                .accessibilityLabel("Disney Plus (Unavailable)")
                        }
                        
                        // Amazon Video
                        let amazonURL = (song.streamingLinks + song.purchaseLinks).first(where: { $0.localizedCaseInsensitiveContains("amazon") })
                        if let url = amazonURL {
                            Link(destination: URL(string: url)!) {
                                Image(systemName: "cart.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.orange)
                                    .accessibilityLabel("Amazon Video")
                            }
                        } else {
                            Image(systemName: "cart.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                                .accessibilityLabel("Amazon Video (Unavailable)")
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
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
