import Foundation

final class GoogleSheetsService {
    static let shared = GoogleSheetsService()

    func fetchSongs(completion: @escaping ([Song]) -> Void) {
        // TODO: Implement networking code to fetch data from Google Sheets
        completion([])
    }
}
