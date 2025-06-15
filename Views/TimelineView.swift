import SwiftUI

struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()

    var body: some View {
        PageCurlView(movies: viewModel.movies, songs: viewModel.songs)
            .onAppear {
                viewModel.load()
            }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
