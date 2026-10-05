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

    private var cuePlayer: AVAudioPlayer?
    private var backgroundPlayer: AVAudioPlayer?

    func prepare() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)

        guard let url = Bundle.main.url(forResource: Cue.silence.rawValue, withExtension: "wav") else { return }
        backgroundPlayer = try? AVAudioPlayer(contentsOf: url)
        backgroundPlayer?.numberOfLoops = -1
        backgroundPlayer?.volume = 1
        backgroundPlayer?.prepareToPlay()
        backgroundPlayer?.play()
    }

    func stop() {
        cuePlayer?.stop()
        backgroundPlayer?.stop()
        cuePlayer = nil
        backgroundPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func play(_ cue: Cue, feedback: AppSettings.Feedback) {
        switch feedback {
        case .silent:
            return
        case .vibration:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        case .tones:
            playTone(cue)
        case .tonesAndVibration:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            playTone(cue)
        }
    }

    private func playTone(_ cue: Cue) {
        guard let url = Bundle.main.url(forResource: cue.rawValue, withExtension: "wav") else { return }
        cuePlayer = try? AVAudioPlayer(contentsOf: url)
        cuePlayer?.volume = 1
        cuePlayer?.prepareToPlay()
        cuePlayer?.play()
    }
}
