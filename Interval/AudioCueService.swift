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
    private var vibrationTask: Task<Void, Never>?

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
        vibrationTask?.cancel()
        cuePlayer?.stop()
        backgroundPlayer?.stop()
        vibrationTask = nil
        cuePlayer = nil
        backgroundPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func play(_ cue: Cue, feedback: AppSettings.Feedback, volume: Double) {
        switch feedback {
        case .silent:
            return
        case .vibration:
            playVibration(for: cue)
        case .tones:
            playTone(cue, volume: volume)
        case .tonesAndVibration:
            playVibration(for: cue)
            playTone(cue, volume: volume)
        }
    }

    private func playVibration(for cue: Cue) {
        vibrationTask?.cancel()
        guard cue != .blop else { return }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        guard cue == .restEnded else { return }
        vibrationTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    private func playTone(_ cue: Cue, volume: Double) {
        guard let url = Bundle.main.url(forResource: cue.rawValue, withExtension: "wav") else { return }
        cuePlayer = try? AVAudioPlayer(contentsOf: url)
        cuePlayer?.volume = Float(min(max(volume, 0), 1))
        cuePlayer?.prepareToPlay()
        cuePlayer?.play()
    }
}
