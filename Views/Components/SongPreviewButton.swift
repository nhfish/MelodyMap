import SwiftUI
import MusicKit

struct SongPreviewButton: View {
    let song: Song
    let movieTitle: String
    @EnvironmentObject private var musicKit: MusicKitService
    @State private var appleMusicSong: MusicKit.Song?
    @State private var isLoading = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        Button(action: handlePreviewTap) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.7)
                    .frame(width: 20, height: 20)
            } else if appleMusicSong != nil {
                AudioPreviewPlayer(previewURL: musicKit.getPreviewURL(for: appleMusicSong!)!)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "play.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.blue.opacity(0.7))
            }
        }
        .disabled(isLoading)
        .alert("Apple Music Access", isPresented: $showPermissionAlert) {
            Button("Allow") {
                Task {
                    await requestPermission()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Melody Map would like to access Apple Music to find song previews.")
        }
    }
    
    private func handlePreviewTap() {
        if musicKit.isAuthorized {
            if appleMusicSong != nil {
                // Preview already loaded, AudioPreviewPlayer will handle playback
                return
            } else {
                // Search for the song
                Task {
                    await searchSong()
                }
            }
        } else {
            // Request permission
            showPermissionAlert = true
        }
    }
    
    private func requestPermission() async {
        let authorized = await musicKit.requestAuthorization()
        if authorized {
            await searchSong()
        }
    }
    
    private func searchSong() async {
        isLoading = true
        defer { isLoading = false }
        
        appleMusicSong = await musicKit.searchSong(movieTitle: movieTitle, songTitle: song.title)
    }
} 