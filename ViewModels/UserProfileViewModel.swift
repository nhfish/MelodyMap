import Foundation

final class UserProfileViewModel: ObservableObject {
    @Published var dailyUsesRemaining: Int = 0
    @Published var isSubscribed: Bool = false
}
