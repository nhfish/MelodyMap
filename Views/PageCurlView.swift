import SwiftUI

struct PageCurlView: UIViewControllerRepresentable {
    var movies: [Movie]

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
        if let first = movies.first {
            let firstVC = context.coordinator.controller(for: first)
            controller.setViewControllers([firstVC], direction: .forward, animated: false)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        context.coordinator.parent = self
        if uiViewController.viewControllers?.isEmpty ?? true, let first = movies.first {
            let firstVC = context.coordinator.controller(for: first)
            uiViewController.setViewControllers([firstVC], direction: .forward, animated: false)
        }
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource {
        var parent: PageCurlView
        private var cache: [String: UIViewController] = [:]

        init(parent: PageCurlView) {
            self.parent = parent
        }

        func controller(for movie: Movie) -> UIViewController {
            if let cached = cache[movie.id] { return cached }
            let vc = UIHostingController(rootView: MoviePageView(movie: movie))
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
