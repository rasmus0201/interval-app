import AVFoundation

@MainActor
final class SpeechCueService {
    static let shared = SpeechCueService()

    private let synthesizer = AVSpeechSynthesizer()
    private lazy var voice = Self.preferredVoice()

    /// Speaks through the workout's audio session. A new cue replaces any cue still speaking.
    func speak(_ cue: SpokenCue, afterTone: Bool) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: cue.text)
        utterance.voice = voice
        utterance.preUtteranceDelay = afterTone && cue.followsPhaseTone ? 1 : 0
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    private static func preferredVoice() -> AVSpeechSynthesisVoice? {
        let localization = Bundle.main.preferredLocalizations.first ?? "en"
        let language = SpeechLanguage.code(
            localization: localization,
            systemLanguageCode: AVSpeechSynthesisVoice.currentLanguageCode()
        )
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let exactMatch = voices
            .filter { $0.language == language }
            .max { $0.quality.rawValue < $1.quality.rawValue }
        return exactMatch
            ?? AVSpeechSynthesisVoice(language: language)
            ?? voices.first { $0.language.hasPrefix(localization) }
    }
}

enum SpeechLanguage {
    /// Picks a voice language that matches the app's text, keeping the person's own regional variant when it fits.
    static func code(localization: String, systemLanguageCode: String) -> String {
        if systemLanguageCode.hasPrefix(localization + "-") {
            return systemLanguageCode
        }
        switch localization {
        case "da": return "da-DK"
        case "en": return "en-US"
        default: return localization
        }
    }
}
