import SwiftUI

struct MainTabView: View {
    @StateObject private var timelineVM = TimelineViewModel()
    @State private var showPaywall = false
    
    var body: some View {
        TabView {
            TimelineView(viewModel: timelineVM)
                .tabItem {
                    Label("Timeline", systemImage: "film")
                }
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .sheet(isPresented: $timelineVM.showingQuotaSheet) {
            QuotaExceededSheet(
                onWatchAd: { timelineVM.watchAd() },
                onUpgrade: { showPaywall = true }
            )
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
