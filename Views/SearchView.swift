import SwiftUI

struct SearchView: View {
    @StateObject private var vm: SearchViewModel
    @EnvironmentObject private var usage: UsageTrackerService
    @EnvironmentObject private var adService: AdService
    var onNavigateToTimeline: ((IndexedSong) -> Void)? = nil

    @State private var showQuotaSheet = false

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
                TextField("Search", text: $vm.query)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .onChange(of: vm.query) { _ in vm.search() }

                if vm.indexedSongs.isEmpty {
                    // Loading state
                    VStack {
                        ProgressView()
                            .padding()
                        Text("Loading songs...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.results.isEmpty && !vm.query.isEmpty {
                    // No results state
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                            .padding()
                        Text("No songs found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Try searching for a different song or movie")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                                                .foregroundColor(.primary)
                                            Text(indexed.movie.title)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
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
        }
        .onAppear {
            print("🎬 SearchView: onAppear called")
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
                }
            )
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(UsageTrackerService.shared)
    }
}
