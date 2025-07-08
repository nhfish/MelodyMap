import SwiftUI

struct SearchView: View {
    @StateObject private var vm: SearchViewModel
    @EnvironmentObject private var usage: UsageTrackerService
    @EnvironmentObject private var adService: AdService
    @EnvironmentObject private var appState: AppState
    var onNavigateToTimeline: ((IndexedSong) -> Void)? = nil

    @State private var showQuotaSheet = false
    @FocusState private var isSearchFocused: Bool

    init(onNavigateToTimeline: ((IndexedSong) -> Void)? = nil) {
        print("🎬 SearchView: init called")
        _vm = StateObject(wrappedValue: SearchViewModel(onNavigateToTimeline: onNavigateToTimeline, adService: AdService.shared))
        self.onNavigateToTimeline = onNavigateToTimeline
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: geo.size.height / 3)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(isSearchFocused ? .appAccent : .appText.opacity(0.6))
                        .padding(.leading, 16)
                    TextField("Search", text: $vm.query)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.appText)
                }
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSearchFocused ? Color.appAccent : Color.appAccent.opacity(0.3), lineWidth: isSearchFocused ? 2 : 1)
                        )
                )
                .scaleEffect(isSearchFocused ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                .padding(.horizontal)
                    .focused($isSearchFocused)
                    .onChange(of: vm.query) { _ in vm.search() }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isSearchFocused = false
                            }
                            .foregroundColor(.yellow) // Match your FAB color
                        }
                    }
                    .onAppear {
                        // Set keyboard appearance to match app theme
                        UITextField.appearance().keyboardAppearance = .dark
                    }

                if vm.indexedSongs.isEmpty {
                    // Loading state
                    VStack {
                        ProgressView()
                            .padding()
                        Text("Loading songs...")
                            .foregroundColor(.appText.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.results.isEmpty && !vm.query.isEmpty {
                    // No results state
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.appText.opacity(0.6))
                            .padding()
                        Text("No songs found")
                            .font(.headline)
                            .foregroundColor(.appText)
                        Text("Try searching for a different song or movie")
                            .font(.caption)
                            .foregroundColor(.appText.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Results list with gradient mask fade at bottom
                    ZStack {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(vm.results, id: \.song.id) { indexed in
                                    Button(action: {
                                        vm.selectSongFromSearch(indexed)
                                    }) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(indexed.song.title)
                                                .bold()
                                                .foregroundColor(.appText)
                                            HStack {
                                                Text(indexed.movie.title)
                                                    .font(.caption)
                                                    .foregroundColor(.appText.opacity(0.7))
                                                if !indexed.song.singers.isEmpty {
                                                    Text("•")
                                                        .font(.caption)
                                                        .foregroundColor(.appText.opacity(0.7))
                                                    Text(indexed.song.singers.joined(separator: ", "))
                                                        .font(.caption)
                                                        .foregroundColor(.appText.opacity(0.7))
                                                }
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .padding(.bottom, geo.size.height / 3)
                        }
                        .mask(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .black, location: 0.0),
                                    .init(color: .black, location: 0.66),
                                    .init(color: .clear, location: 1.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                Spacer(minLength: 0)
            }
            .edgesIgnoringSafeArea(.bottom)
            .onTapGesture {
                // Dismiss keyboard when tapping outside the search field
                isSearchFocused = false
            }
        }
        .background(Color.appBackground)
        .onAppear {
            print("🎬 SearchView: onAppear called")
        }
        .onChange(of: appState.showingTimelineSheet) { showing in
            if !showing {
                // Reset search when timeline sheet is closed
                vm.query = ""
                vm.results = []
            }
        }
        .onReceive(vm.$shouldShowQuotaSheet) { value in
            print("🎬 SearchView: shouldShowQuotaSheet changed to \(value)")
            showQuotaSheet = value
        }
        .sheet(isPresented: $showQuotaSheet, onDismiss: { vm.dismissQuotaSheet() }) {
            QuotaExceededSheet(
                onWatchAd: {
                    print("🎬 SearchView: Watch Ad button tapped")
                    vm.watchAd()
                    showQuotaSheet = false
                },
                onUpgrade: {
                    print("🎬 SearchView: Upgrade button tapped")
                    // TODO: Implement upgrade flow
                    showQuotaSheet = false
                },
                onDismiss: {
                    print("🎬 SearchView: Dismiss button tapped")
                    showQuotaSheet = false
                }
            )
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(UsageTrackerService.shared)
            .environmentObject(AppState())
    }
}
