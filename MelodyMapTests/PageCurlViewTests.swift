import XCTest
import SwiftUI
@testable import MelodyMap

final class PageCurlViewTests: XCTestCase {
    func testCoordinatorCreatesViewControllersForMovies() {
        let movies: [Movie] = [
            Movie(id: "1", title: "One", imageURL: "", releaseYear: 2000, sortOrder: 0),
            Movie(id: "2", title: "Two", imageURL: "", releaseYear: 2001, sortOrder: 1),
            Movie(id: "3", title: "Three", imageURL: "", releaseYear: 2002, sortOrder: 2)
        ]
        let view = PageCurlView(movies: movies)
        let coordinator = PageCurlView.Coordinator(parent: view)
        let controllers = movies.map { coordinator.controller(for: $0) }
        let uniqueIdentifiers = Set(controllers.map { ObjectIdentifier($0) })
        XCTAssertEqual(uniqueIdentifiers.count, movies.count)
    }
}
