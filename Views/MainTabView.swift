// DEPRECATED: MainTabView is no longer used. See MelodyMapApp.swift for new navigation.
import SwiftUI

struct MainTabView: View {
    @StateObject private var timelineVM = TimelineViewModel()
    @StateObject private var searchVM = SearchViewModel()
    @State private var showPaywall = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimelineView(viewModel: timelineVM)
                .tabItem {
                    Label("Timeline", systemImage: "film")
                }
                .tag(0)
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
        }
        .onChange(of: searchVM.selectedIndexedSong) { indexedSong in
            if let indexedSong = indexedSong {
                timelineVM.navigateToMovieWithSong(indexedSong)
                searchVM.selectedIndexedSong = nil
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
