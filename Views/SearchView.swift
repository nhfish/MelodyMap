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
        NavigationView {
            VStack {
                TextField("Search", text: $vm.query)
                    .textFieldStyle(.roundedBorder)
                    .padding([.horizontal, .top])
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
                    // Results list
                    List(vm.results, id: \.song.id) { indexed in
                        Button(action: {
                            vm.selectSongFromSearch(indexed)
                        }) {
                            VStack(alignment: .leading) {
                                Text(indexed.song.title)
                                    .bold()
                                    .foregroundColor(.primary)
                                Text(indexed.movie.title)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
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
