import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()

    var body: some View {
        Form {
            Section(header: Text("Subscription")) {
                Text(viewModel.isSubscribed ? "Subscribed" : "Free User")
            }
            Section(header: Text("Daily Uses")) {
                Text("Remaining: \(viewModel.dailyUsesRemaining)")
            }
        }
        .navigationTitle("Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
