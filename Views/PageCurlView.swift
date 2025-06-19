import SwiftUI

struct PageCurlView: UIViewControllerRepresentable {
    var movies: [Movie]
    var songs: [Song]
    var currentMovieIndex: Int = 0
    var preSelectedSong: Song?
    var onSongSelected: (Song) -> Void
    
    // Public initializer
    init(movies: [Movie], songs: [Song], currentMovieIndex: Int = 0, preSelectedSong: Song? = nil, onSongSelected: @escaping (Song) -> Void) {
        self.movies = movies
        self.songs = songs
        self.currentMovieIndex = currentMovieIndex
        self.preSelectedSong = preSelectedSong
        self.onSongSelected = onSongSelected
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal
        )
        controller.dataSource = context.coordinator
        if let scrollView = controller.view.subviews.compactMap({ $0 as? UIScrollView }).first {
            scrollView.bounces = false
        }
        
        // Set initial view controller based on currentMovieIndex
        if !movies.isEmpty {
            let initialIndex = min(currentMovieIndex, movies.count - 1)
            let initialMovie = movies[initialIndex]
            let firstVC = context.coordinator.controller(for: initialMovie)
            controller.setViewControllers([firstVC], direction: .forward, animated: false)
            context.coordinator.lastSetMovieIndex = initialIndex
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        // Only update if there are actual changes
        let hasMoviesChanged = context.coordinator.parent.movies.count != movies.count
        let hasIndexChanged = context.coordinator.parent.currentMovieIndex != currentMovieIndex
        let hasSongChanged = context.coordinator.parent.preSelectedSong?.id != preSelectedSong?.id
        
        // Update the parent reference
        context.coordinator.parent = self
        
        // Only proceed if there are actual changes
        guard hasMoviesChanged || hasIndexChanged || hasSongChanged else {
            return
        }
        
        print("🔄 PageCurlView updateUIViewController - movies: \(movies.count), currentMovieIndex: \(currentMovieIndex), lastSet: \(context.coordinator.lastSetMovieIndex)")
        
        // Handle navigation to specific movie only if it's different from the last set
        if !movies.isEmpty && currentMovieIndex < movies.count && currentMovieIndex != context.coordinator.lastSetMovieIndex {
            let targetMovie = movies[currentMovieIndex]
            let targetVC = context.coordinator.controller(for: targetMovie)
            
            // Check if we're already showing the correct view controller
            if let currentVC = uiViewController.viewControllers?.first,
               currentVC === targetVC {
                // Already showing the correct view controller, just update the index
                context.coordinator.lastSetMovieIndex = currentMovieIndex
                print("🔄 Already showing correct movie: \(targetMovie.title)")
                return
            }
            
            print("🎯 Target movie: \(targetMovie.title) at index \(currentMovieIndex)")
            
            // Set the view controller without animation to prevent automatic page curl
            uiViewController.setViewControllers([targetVC], direction: .forward, animated: false)
            context.coordinator.lastSetMovieIndex = currentMovieIndex
            print("✅ Navigated to movie: \(targetMovie.title)")
        } else if uiViewController.viewControllers?.isEmpty ?? true, let first = movies.first {
            let firstVC = context.coordinator.controller(for: first)
            uiViewController.setViewControllers([firstVC], direction: .forward, animated: false)
            context.coordinator.lastSetMovieIndex = 0
            print("🔄 Set initial movie: \(first.title)")
        }
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource {
        var parent: PageCurlView
        var cache: [String: UIViewController] = [:]
        var lastSetMovieIndex: Int = -1

        init(parent: PageCurlView) {
            self.parent = parent
        }

        func controller(for movie: Movie) -> UIViewController {
            if let cached = cache[movie.id] { return cached }
            let songsForMovie = parent.songs.filter { $0.movieId == movie.id }
            let vc = UIHostingController(rootView: MoviePageView(
                movie: movie, 
                songs: songsForMovie, 
                preSelectedSong: parent.preSelectedSong,
                onSongSelected: parent.onSongSelected
            ))
            cache[movie.id] = vc
            return vc
        }

        private func index(of viewController: UIViewController) -> Int? {
            for (index, movie) in parent.movies.enumerated() {
                if cache[movie.id] === viewController { return index }
            }
            return nil
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = index(of: viewController), index > 0 else { return nil }
            let movie = parent.movies[index - 1]
            return controller(for: movie)
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = index(of: viewController), index + 1 < parent.movies.count else { return nil }
            let movie = parent.movies[index + 1]
            return controller(for: movie)
        }
    }
}
