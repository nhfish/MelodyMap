import SwiftUI

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search", text: $vm.query)
                    .searchFieldStyle(.roundedBorder)
                    .padding([.horizontal, .top])
                    .onChange(of: vm.query) { _ in vm.search() }

                List(vm.results, id: \.song.id) { indexed in
                    VStack(alignment: .leading) {
                        Text(indexed.song.title)
                            .bold()
                        Text(indexed.movie.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        print(indexed.song.id)
                        print(indexed.song.movieId)
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
