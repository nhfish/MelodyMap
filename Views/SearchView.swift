import SwiftUI

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()
    @EnvironmentObject private var usage: UsageTrackerService

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search", text: $vm.query)
                    .textFieldStyle(.roundedBorder)
                    .padding([.horizontal, .top])
                    .onChange(of: vm.query) { _ in vm.search() }

                List(vm.results, id: \.song.id) { indexed in
                    NavigationLink(destination: SongDetailView(song: indexed.song)) {
                        VStack(alignment: .leading) {
                            Text(indexed.song.title)
                                .bold()
                            Text(indexed.movie.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
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
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(UsageTrackerService.shared)
    }
}
