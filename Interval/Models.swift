import Foundation

struct WorkoutConfiguration: Codable, Equatable, Hashable {
    var workSeconds = 45
    var restSeconds = 15
    var repetitions = 8
    var rounds = 3
    var roundRestSeconds = 0

    var workIntervalCount: Int {
        repetitions * rounds
    }

    var durationWithoutWarmup: Int {
        let work = workSeconds * repetitions * rounds
        let breaksBetweenRounds = (restSeconds + roundRestSeconds) * max(rounds - 1, 0)
        return work + breaksBetweenRounds
    }
}

struct AppSettings: Codable, Equatable {
    enum Feedback: String, Codable, CaseIterable, Identifiable {
        case silent
        case vibration
        case tones
        case tonesAndVibration

        var id: Self { self }

        var title: String {
            switch self {
            case .silent: "Lydløs"
            case .vibration: "Vibration"
            case .tones: "Biptoner"
            case .tonesAndVibration: "Bip + vibration"
            }
        }

        var usesTones: Bool {
            self == .tones || self == .tonesAndVibration
        }

        var usesVibration: Bool {
            self == .vibration || self == .tonesAndVibration
        }

        init(usesTones: Bool, usesVibration: Bool) {
            switch (usesTones, usesVibration) {
            case (false, false): self = .silent
            case (false, true): self = .vibration
            case (true, false): self = .tones
            case (true, true): self = .tonesAndVibration
            }
        }
    }

    var startCountdownSeconds = 10
    var feedback = Feedback.tones
    var cueVolume = 1.0

    var tonesEnabled: Bool {
        get { feedback.usesTones }
        set { feedback = Feedback(usesTones: newValue, usesVibration: vibrationEnabled) }
    }

    var vibrationEnabled: Bool {
        get { feedback.usesVibration }
        set { feedback = Feedback(usesTones: tonesEnabled, usesVibration: newValue) }
    }

    private enum CodingKeys: String, CodingKey {
        case startCountdownSeconds
        case feedback
        case cueVolume
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startCountdownSeconds = try container.decodeIfPresent(Int.self, forKey: .startCountdownSeconds) ?? 10
        feedback = try container.decodeIfPresent(Feedback.self, forKey: .feedback) ?? .tones
        cueVolume = try container.decodeIfPresent(Double.self, forKey: .cueVolume) ?? 1
    }
}

struct WorkoutHistoryEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let completedAt: Date
    let configuration: WorkoutConfiguration
    let startCountdownSeconds: Int

    init(
        id: UUID = UUID(),
        completedAt: Date = .now,
        configuration: WorkoutConfiguration,
        startCountdownSeconds: Int
    ) {
        self.id = id
        self.completedAt = completedAt
        self.configuration = configuration
        self.startCountdownSeconds = startCountdownSeconds
    }

    var totalSeconds: Int {
        configuration.durationWithoutWarmup
    }
}

enum WorkoutPhase: String, Codable, Equatable {
    case warmup
    case work
    case rest
    case roundRest

    var title: String {
        switch self {
        case .warmup: "Gør klar"
        case .work: "Arbejde"
        case .rest: "Hvile"
        case .roundRest: "Rundepause"
        }
    }

    var symbol: String {
        switch self {
        case .warmup: "figure.run"
        case .work: "bolt.fill"
        case .rest: "pause.fill"
        case .roundRest: "arrow.trianglehead.2.clockwise.rotate.90"
        }
    }
}

struct WorkoutStep: Equatable {
    let phase: WorkoutPhase
    let duration: Int
    let repetition: Int
    let round: Int
}

enum WorkoutTimeline {
    static func steps(configuration: WorkoutConfiguration, startCountdownSeconds: Int) -> [WorkoutStep] {
        let warmup = startCountdownSeconds > 0
            ? [WorkoutStep(phase: .warmup, duration: startCountdownSeconds, repetition: 0, round: 0)]
            : []

        let workout = (1...configuration.rounds).flatMap { round in
            let repetitions = (1...configuration.repetitions).map { repetition in
                WorkoutStep(
                    phase: .work,
                    duration: configuration.workSeconds,
                    repetition: repetition,
                    round: round
                )
            }

            let breakDuration = configuration.restSeconds + configuration.roundRestSeconds
            let roundBreak = round < configuration.rounds && breakDuration > 0
                ? [WorkoutStep(
                    phase: configuration.roundRestSeconds > 0 ? .roundRest : .rest,
                    duration: breakDuration,
                    repetition: configuration.repetitions,
                    round: round
                )]
                : []
            return repetitions + roundBreak
        }

        return warmup + workout
    }
}

extension Int {
    var timerText: String {
        String(format: "%02d:%02d", self / 60, self % 60)
    }

    var shortDurationText: String {
        if self < 60 {
            return "\(self) sek"
        }
        let minutes = self / 60
        let seconds = self % 60
        return seconds == 0 ? "\(minutes) min" : "\(minutes) min \(seconds) sek"
    }
}
