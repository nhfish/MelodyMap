import SwiftUI

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()
    @EnvironmentObject private var usage: UsageTrackerService
    @Binding var selectedTab: Int

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
        .overlay(alignment: .topTrailing) {
            UsageMeterView()
                .padding()
        }
        .sheet(isPresented: $vm.showingQuotaSheet) {
            QuotaExceededSheet(
                onWatchAd: { vm.watchAd() },
                onUpgrade: { /* TODO: Implement paywall */ }
            )
        }
        .onChange(of: vm.navigateToTimeline) { shouldNavigate in
            if shouldNavigate {
                selectedTab = 0 // Switch to timeline tab
                vm.navigateToTimeline = false
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(selectedTab: .constant(0))
            .environmentObject(UsageTrackerService.shared)
    }
}
