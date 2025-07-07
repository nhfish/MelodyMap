import SwiftUI
import AVFoundation

struct AudioPreviewPlayer: View {
    let previewURL: URL
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioPlayerDelegate: AudioPlayerDelegate? // Retain delegate
    @State private var isLooping = true // Auto-loop by default
    
    var body: some View {
        Button(action: togglePlayback) {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.blue)
        }
        .onAppear {
            // Auto-play when the player appears
            startPlayback()
        }
        .onDisappear {
            stopPlayback()
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            resumePlayback()
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
                let delegate = AudioPlayerDelegate { [isLooping] in
                    DispatchQueue.main.async {
                        if isLooping {
                            // Auto-loop: restart the same player
                            audioPlayer?.currentTime = 0
                            audioPlayer?.play()
                        } else {
                            // Stop playing
                            isPlaying = false
                        }
                    }
                }
                let player = try AVAudioPlayer(data: data)
                player.delegate = delegate
                player.numberOfLoops = 0 // We'll handle looping manually for better control
                audioPlayerDelegate = delegate // Retain delegate
                audioPlayer = player
                player.play()
                isPlaying = true
            } catch {
                print("Audio preview error: \(error)")
            }
        }
    }
    
    private func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    private func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        audioPlayerDelegate = nil // Release delegate
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
