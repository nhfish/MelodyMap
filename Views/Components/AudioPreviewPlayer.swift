import SwiftUI
import AVFoundation

struct AudioPreviewPlayer: View {
    let previewURL: URL
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        Button(action: togglePlayback) {
            Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.blue)
        }
        .onDisappear {
            stopPlayback()
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        guard audioPlayer == nil else {
            audioPlayer?.play()
            isPlaying = true
            return
        }
        
        Task {
            do {
                let data = try await URLSession.shared.data(from: previewURL).0
                let player = try AVAudioPlayer(data: data)
                player.delegate = AudioPlayerDelegate { 
                    DispatchQueue.main.async {
                        isPlaying = false
                    }
                }
                audioPlayer = player
                player.play()
                isPlaying = true
            } catch {
                print("Audio preview error: \(error)")
            }
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
}

// Helper class to handle audio player delegate
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    private let onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
} 