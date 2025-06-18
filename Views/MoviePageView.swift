import SwiftUI

struct MoviePageView: View {
    let movie: Movie
    let songs: [Song]
    let preSelectedSong: Song?
    let onSongSelected: (Song) -> Void

    private var songsForMovie: [Song] {
        songs.filter { $0.movieId == movie.id }
    }

    @State private var selectedIndex: Int = 0
    @State private var hasHandledPreSelectedSong = false

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
                    ZStack {
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.secondary)
                            ForEach(Array(songsForMovie.enumerated()), id: \.element.id) { index, song in
                                Circle()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(song.id == preSelectedSong?.id ? .blue : .primary)
                                    .position(x: geo.size.width * CGFloat(song.percent ?? 0) / 100,
                                              y: 1)
                                    .onTapGesture {
                                        selectedIndex = index
                                        withAnimation {
                                            proxy.scrollTo(song.id, anchor: .top)
                                        }
                                    }
                            }
                        }
                        HStack {
                            Button(action: {
                                guard selectedIndex > 0 else { return }
                                selectedIndex -= 1
                                let song = songsForMovie[selectedIndex]
                                withAnimation { proxy.scrollTo(song.id, anchor: .top) }
                            }) {
                                Image(systemName: "chevron.left")
                                    .frame(width: 44, height: 44)
                            }
                            Spacer()
                            Button(action: {
                                guard selectedIndex + 1 < songsForMovie.count else { return }
                                selectedIndex += 1
                                let song = songsForMovie[selectedIndex]
                                withAnimation { proxy.scrollTo(song.id, anchor: .top) }
                            }) {
                                Image(systemName: "chevron.right")
                                    .frame(width: 44, height: 44)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                let ratio = min(max(0, value.location.x / geo.size.width), 1)
                                let nearestIndex = songsForMovie.enumerated().min { lhs, rhs in
                                    let l = abs(ratio - CGFloat(lhs.element.percent ?? 0) / 100)
                                    let r = abs(ratio - CGFloat(rhs.element.percent ?? 0) / 100)
                                    return l < r
                                }?.offset ?? selectedIndex
                                selectedIndex = nearestIndex
                                let nearest = songsForMovie[nearestIndex]
                                withAnimation {
                                    proxy.scrollTo(nearest.id, anchor: .top)
                                }
                            }
                    )
                }
                .frame(height: 44)

                let currentSong = songsForMovie[selectedIndex]
                VStack(alignment: .leading, spacing: 4) {
                    Text((currentSong.startTime ?? "00:00:00") + "  ·  \(currentSong.percent ?? 0)%")
                        .font(.caption)
                    Divider()
                    HStack {
                        Text(currentSong.title)
                            .bold()
                        StarButton()
                    }
                    Text("\(movie.title) · \(movie.releaseYear)")
                    Text("Characters: " + currentSong.singers.joined(separator: ", "))
                }
                .onTapGesture { 
                    onSongSelected(currentSong)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(songsForMovie) { song in
                            Text(song.title)
                                .id(song.id)
                                .padding(.vertical, 4)
                                .background(song.id == preSelectedSong?.id ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(4)
                                .onTapGesture { 
                                    onSongSelected(song)
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                handlePreSelectedSong(proxy: proxy)
            }
            .onChange(of: preSelectedSong) { song in
                if song != nil && !hasHandledPreSelectedSong {
                    handlePreSelectedSong(proxy: proxy)
                }
            }
        }
    }
    
    private func handlePreSelectedSong(proxy: ScrollViewProxy) {
        guard let preSelectedSong = preSelectedSong,
              !hasHandledPreSelectedSong,
              let songIndex = songsForMovie.firstIndex(where: { $0.id == preSelectedSong.id }) else {
            return
        }
        
        selectedIndex = songIndex
        hasHandledPreSelectedSong = true
        
        // Scroll to the pre-selected song with a slight delay to ensure the view is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.5)) {
                proxy.scrollTo(preSelectedSong.id, anchor: UnitPoint.top)
            }
        }
    }
}

struct MoviePageView_Previews: PreviewProvider {
    static var previews: some View {
        MoviePageView(
            movie: Movie(id: "1", title: "Sample Movie", imageURL: "https://example.com/poster.jpg", releaseYear: 2024, sortOrder: 1),
            songs: [
                Song(id: "song1", movieId: "1", title: "First", percent: 10, startTime: "00:01:00", singers: [], releaseYear: 2024, movieRuntimeMinutes: 90, streamingLinks: [], purchaseLinks: [], keywords: [], blurb: "Sample blurb")
            ],
            preSelectedSong: nil,
            onSongSelected: { song in
                print("Song selected: \(song.title)")
            }
        )
    }
}
