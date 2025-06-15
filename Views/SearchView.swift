import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.results) { song in
                NavigationLink(destination: SongDetailView(song: song)) {
                    Text(song.title)
                }
            }
            .navigationTitle("Search")
            .searchable(text: $viewModel.query)
            .onChange(of: viewModel.query) { _ in
                viewModel.search()
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
