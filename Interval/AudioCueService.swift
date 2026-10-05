import AVFoundation
import AudioToolbox

@MainActor
final class AudioCueService {
    enum Cue: String {
        case start = "start-signal"
        case workEnded = "work-end-signal"
        case restEnded = "rest-end-signal"
        case complete = "complete-signal"
        case blop
        case silence
    }

    static let shared = AudioCueService()

    private var player: AVAudioPlayer?

    func prepare() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.duckOthers])
        try? session.setActive(true)
    }

    func play(_ cue: Cue, feedback: AppSettings.Feedback) {
        switch feedback {
        case .silent:
            return
        case .vibration:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        case .tones:
            guard let url = Bundle.main.url(forResource: cue.rawValue, withExtension: "wav") else { return }
            player = try? AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        }
    }
}
