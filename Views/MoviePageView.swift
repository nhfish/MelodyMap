import SwiftUI

struct MoviePageView: View {
    let movie: Movie
    let songs: [Song]
    let preSelectedSong: Song?
    let onSongSelected: (Song) -> Void
    @EnvironmentObject private var usage: UsageTrackerService

    private var songsForMovie: [Song] {
        songs.filter { $0.movieId == movie.id }
    }

    @State private var selectedIndex: Int = 0
    @State private var hasHandledPreSelectedSong = false
    @State private var showQuotaSheet = false

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
                                // Consume a daily use before navigating
                                if usage.canConsume() {
                                    usage.consumeView()
                                    selectedIndex -= 1
                                    let song = songsForMovie[selectedIndex]
                                    withAnimation { proxy.scrollTo(song.id, anchor: .top) }
                                    print("✅ MoviePageView: Navigated to previous song '\(song.title)'")
                                } else {
                                    showQuotaSheet = true
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .frame(width: 44, height: 44)
                            }
                            .disabled(selectedIndex <= 0)
                            Spacer()
                            Button(action: {
                                guard selectedIndex + 1 < songsForMovie.count else { return }
                                // Consume a daily use before navigating
                                if usage.canConsume() {
                                    usage.consumeView()
                                    selectedIndex += 1
                                    let song = songsForMovie[selectedIndex]
                                    withAnimation { proxy.scrollTo(song.id, anchor: .top) }
                                    print("✅ MoviePageView: Navigated to next song '\(song.title)'")
                                } else {
                                    showQuotaSheet = true
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .frame(width: 44, height: 44)
                            }
                            .disabled(selectedIndex + 1 >= songsForMovie.count)
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
                    Text(formatTimecode(currentSong.startTime) + "  ·  \(currentSong.percent ?? 0)%")
                        .font(.caption)
                    Divider()
                    HStack {
                        Text(currentSong.title)
                            .bold()
                        StarButton()
                    }
                    Text("\(movie.title) · \(String(movie.releaseYear))")
                    Text("Characters: " + currentSong.singers.joined(separator: ", "))
                }
                .onTapGesture { 
                    onSongSelected(currentSong)
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
            .sheet(isPresented: $showQuotaSheet) {
                QuotaExceededSheet(
                    onWatchAd: { showQuotaSheet = false },
                    onUpgrade: { showQuotaSheet = false }
                )
                .environmentObject(usage)
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

    /// Ensures the timecode is always displayed as HH:MM:SS
    private func formatTimecode(_ time: String?) -> String {
        guard let time = time, !time.isEmpty else { return "00:00:00" }
        let parts = time.split(separator: ":").map { String($0) }
        if parts.count == 3 {
            // Already HH:MM:SS
            return String(format: "%02d:%02d:%02d",
                          Int(parts[0]) ?? 0,
                          Int(parts[1]) ?? 0,
                          Int(parts[2]) ?? 0)
        } else if parts.count == 2 {
            // MM:SS, pad with 00 for hours
            return String(format: "00:%02d:%02d",
                          Int(parts[0]) ?? 0,
                          Int(parts[1]) ?? 0)
        } else if parts.count == 1 {
            // SS only
            return String(format: "00:00:%02d", Int(parts[0]) ?? 0)
        } else {
            return "00:00:00"
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
        .environmentObject(UsageTrackerService.shared)
    }
}
