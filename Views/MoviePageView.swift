import SwiftUI

struct MoviePageView: View {
    let movie: Movie
    let songs: [Song]
    let preSelectedSong: Song?
    let onSongSelected: (Song) -> Void
    @EnvironmentObject private var usage: UsageTrackerService
    @EnvironmentObject private var favorites: FavoritesService
    @StateObject private var keyboard = KeyboardObserver()

    private var songsForMovie: [Song] {
        songs.filter { $0.movieId == movie.id }
    }

    @State private var selectedIndex: Int = 0
    @State private var hasHandledPreSelectedSong = false
    @State private var showQuotaSheet = false
    @State private var isExpanded = false

    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                VStack(spacing: 10) {
                    ZStack {
                        Spacer().frame(height: 10)
                    }
                    .allowsHitTesting(false)
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
                                    .foregroundColor(.appText.opacity(0.3))
                                ForEach(Array(songsForMovie.enumerated()), id: \.element.id) { index, song in
                                    let percent = song.effectivePercent
                                    let xPosition = geo.size.width * CGFloat(percent) / 100.0
                                    TimelineMarker(
                                        isSelected: song.id == songsForMovie[selectedIndex].id,
                                        xPosition: xPosition,
                                        onTap: {
                                            if !keyboard.isKeyboardVisible {
                                                selectedIndex = index
                                                withAnimation {
                                                    proxy.scrollTo(song.id, anchor: .top)
                                                }
                                            }
                                        },
                                        onAppear: {
                                            print("🎯 Timeline dot for '\(song.title)': percent=\(percent)%, xPosition=\(xPosition), geo.width=\(geo.size.width)")
                                            print("🎯 Raw percent value: \(song.percent ?? 0.0), effective percent: \(song.effectivePercent)")
                                        }
                                    )
                                    .allowsHitTesting(!keyboard.isKeyboardVisible)
                                }
                            }
                            HStack {
                                Button(action: {
                                    if !keyboard.isKeyboardVisible {
                                        guard selectedIndex > 0 else { return }
                                        let songToView = songsForMovie[selectedIndex - 1]
                                        // Consume a daily use before navigating
                                        if usage.canViewSong(withId: songToView.id) {
                                            usage.consumeUse(forSongId: songToView.id)
                                            selectedIndex -= 1
                                            withAnimation { proxy.scrollTo(songToView.id, anchor: .top) }
                                            print("✅ MoviePageView: Navigated to previous song '\(songToView.title)'")
                                        } else {
                                            showQuotaSheet = true
                                        }
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .frame(width: 44, height: 44)
                                        .foregroundColor(.appAccent)
                                }
                                .disabled(selectedIndex <= 0 || keyboard.isKeyboardVisible)
                                Spacer()
                                Button(action: {
                                    if !keyboard.isKeyboardVisible {
                                        guard selectedIndex + 1 < songsForMovie.count else { return }
                                        let songToView = songsForMovie[selectedIndex + 1]
                                        // Consume a daily use before navigating
                                        if usage.canViewSong(withId: songToView.id) {
                                            usage.consumeUse(forSongId: songToView.id)
                                            selectedIndex += 1
                                            withAnimation { proxy.scrollTo(songToView.id, anchor: .top) }
                                            print("✅ MoviePageView: Navigated to next song '\(songToView.title)'")
                                        } else {
                                            showQuotaSheet = true
                                        }
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .frame(width: 44, height: 44)
                                        .foregroundColor(.appAccent)
                                }
                                .disabled(selectedIndex + 1 >= songsForMovie.count || keyboard.isKeyboardVisible)
                            }
                        }
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if !keyboard.isKeyboardVisible {
                                        let ratio = min(max(0, value.location.x / geo.size.width), 1)
                                        let nearestIndex = songsForMovie.enumerated().min { lhs, rhs in
                                            let l = abs(ratio - CGFloat(lhs.element.effectivePercent) / 100.0)
                                            let r = abs(ratio - CGFloat(rhs.element.effectivePercent) / 100.0)
                                            return l < r
                                        }?.offset ?? selectedIndex
                                        selectedIndex = nearestIndex
                                        let nearest = songsForMovie[nearestIndex]
                                        withAnimation {
                                            proxy.scrollTo(nearest.id, anchor: .top)
                                        }
                                    }
                                }
                        )
                    }
                    .frame(height: 44)

                    let currentSong = songsForMovie[selectedIndex]
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 10) {
                            Text(formatTimecode(currentSong.startTime))
                                .font(.caption)
                                .foregroundColor(.appText)
                                .onAppear {
                                    print("🕐 Timecode for '\(currentSong.title)': original='\(currentSong.startTime ?? "nil")', formatted='\(formatTimecode(currentSong.startTime))'")
                                }
                            SongPreviewButton(song: currentSong, movieTitle: movie.title)
                                .id(currentSong.id) // Force reset when song changes
                            let isStarredBinding = Binding(
                                get: { favorites.isFavorite(songID: currentSong.id) },
                                set: { _ in favorites.toggleFavorite(songID: currentSong.id) }
                            )
                            StarButton(isStarred: isStarredBinding)
                                .frame(width: 10.0, height: 10.0)
                        }
                        Divider()
                        HStack {
                            Text(currentSong.title)
                                .bold()
                                .foregroundColor(.appText)
                        }
                        Text("\(movie.title) · \(String(movie.releaseYear))")
                            .foregroundColor(.appText)
                        Text("Runtime: \(currentSong.movieRuntimeMinutes) minutes")
                            .foregroundColor(.appText)
                        Text("Characters: " + currentSong.singers.joined(separator: ", "))
                            .foregroundColor(.appText)
                        // Chevron for expanding/collapsing details
                        HStack {
                            Spacer()
                            Button(action: { withAnimation { isExpanded.toggle() } }) {
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.appAccent)
                                    .padding(.top, 4)
                            }
                            .accessibilityLabel(isExpanded ? "Hide Song Details" : "Show Song Details")
                            Spacer()
                        }
                        // Expanded details
                        if isExpanded {
                            VStack(alignment: .leading, spacing: 8) {
                                Spacer().frame(height: 8) // Add buffer above icon row
                                // Service icons row
                                HStack(spacing: 20) {
                                    // Apple Music
                                    let appleMusicURL = (currentSong.streamingLinks + currentSong.purchaseLinks).first(where: { $0.localizedCaseInsensitiveContains("music.apple.com") || $0.localizedCaseInsensitiveContains("apple.com/music") })
                                    if let url = appleMusicURL {
                                        Link(destination: URL(string: url)!) {
                                            Image(systemName: "music.note")
                                                .resizable()
                                                .frame(width: 28, height: 28)
                                                .foregroundColor(.appAccent)
                                                .accessibilityLabel("Apple Music")
                                        }
                                    } else {
                                        Image(systemName: "music.note")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .foregroundColor(.gray)
                                            .opacity(0.5)
                                            .accessibilityLabel("Apple Music (Unavailable)")
                                    }
                                    
                                    // Apple Movie Store
                                    let appleURL = (currentSong.streamingLinks + currentSong.purchaseLinks).first(where: { $0.localizedCaseInsensitiveContains("itunes") || $0.localizedCaseInsensitiveContains("apple.com/movies") })
                                    if let url = appleURL {
                                        Link(destination: URL(string: url)!) {
                                                                            Image(systemName: "applelogo")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .foregroundColor(.appAccent)
                                            .accessibilityLabel("Apple Movie Store")
                                        }
                                    } else {
                                        Image(systemName: "applelogo")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .foregroundColor(.gray)
                                            .opacity(0.5)
                                            .accessibilityLabel("Apple Movie Store (Unavailable)")
                                    }
                                    
                                    // Disney+
                                    let disneyURL = (currentSong.streamingLinks + currentSong.purchaseLinks).first(where: { $0.localizedCaseInsensitiveContains("disney") })
                                    if let url = disneyURL {
                                        Link(destination: URL(string: url)!) {
                                                                            Image(systemName: "play.rectangle.fill")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .foregroundColor(.appAccent)
                                            .accessibilityLabel("Disney Plus")
                                        }
                                    } else {
                                        Image(systemName: "play.rectangle.fill")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .foregroundColor(.gray)
                                            .opacity(0.5)
                                            .accessibilityLabel("Disney Plus (Unavailable)")
                                    }
                                    
                                    // Amazon Video
                                    let amazonURL = (currentSong.streamingLinks + currentSong.purchaseLinks).first(where: { $0.localizedCaseInsensitiveContains("amazon") })
                                    if let url = amazonURL {
                                        Link(destination: URL(string: url)!) {
                                                                            Image(systemName: "cart.fill")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .foregroundColor(.appAccent)
                                            .accessibilityLabel("Amazon Video")
                                        }
                                    } else {
                                        Image(systemName: "cart.fill")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .foregroundColor(.gray)
                                            .opacity(0.5)
                                            .accessibilityLabel("Amazon Video (Unavailable)")
                                    }
                                }
                                
                                if let blurb = currentSong.blurb, !blurb.isEmpty {
                                    Text("\n" + blurb).font(.body).foregroundColor(.appText)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
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
                        onUpgrade: { showQuotaSheet = false },
                        onDismiss: { showQuotaSheet = false }
                    )
                    .environmentObject(usage)
                }
                // Overlay tap-to-dismiss layer when keyboard is visible
                if keyboard.isKeyboardVisible {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                        }
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

    /// Ensures the timecode is always displayed as HH:MM:SS
    private func formatTimecode(_ time: String?) -> String {
        guard let time = time, !time.isEmpty else { 
            return "00:00:00" 
        }
        let parts = time.split(separator: ":").map { String($0) }
        
        if parts.count == 3 {
            // Handle possible decimals in seconds (e.g., 00:24:32.000)
            let hours = Int(parts[0]) ?? 0
            let minutes = Int(parts[1]) ?? 0
            let secondsString = parts[2].split(separator: ".").first.map(String.init) ?? parts[2]
            let seconds = Int(secondsString) ?? 0
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else if parts.count == 2 {
            // MM:SS, pad with 00 for hours
            let minutes = Int(parts[0]) ?? 0
            let secondsString = parts[1].split(separator: ".").first.map(String.init) ?? parts[1]
            let seconds = Int(secondsString) ?? 0
            return String(format: "00:%02d:%02d", minutes, seconds)
        } else if parts.count == 1 {
            // SS only
            let secondsString = parts[0].split(separator: ".").first.map(String.init) ?? parts[0]
            let seconds = Int(secondsString) ?? 0
            return String(format: "00:00:%02d", seconds)
        } else {
            return "00:00:00"
        }
    }
}

struct TimelineMarker: View {
    let isSelected: Bool
    let xPosition: CGFloat
    let onTap: () -> Void
    let onAppear: () -> Void

    var body: some View {
        Group {
            if isSelected {
                Circle()
                    .frame(width: 13, height: 13)
                    .foregroundColor(.appAccent)
            } else {
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.warmOffWhite)
                    .overlay(
                        Circle()
                            .stroke(Color.appText.opacity(0.3), lineWidth: 2)
                    )
            }
        }
        .position(x: xPosition, y: 1)
        .onTapGesture(perform: onTap)
        .onAppear(perform: onAppear)
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
        .environmentObject(FavoritesService.shared)
    }
}
