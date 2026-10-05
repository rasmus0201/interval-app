import Foundation

struct WorkoutConfiguration: Codable, Equatable, Hashable {
    var workSeconds = 45
    var restSeconds = 15
    var repetitions = 8
    var rounds = 3
    var roundRestSeconds = 60

    var workIntervalCount: Int {
        repetitions * rounds
    }

    var durationWithoutWarmup: Int {
        let work = workSeconds * repetitions * rounds
        let restsWithinRounds = restSeconds * max(repetitions - 1, 0) * rounds
        let roundPauses = roundRestSeconds * max(rounds - 1, 0)
        return work + restsWithinRounds + roundPauses
    }
}

struct AppSettings: Codable, Equatable {
    enum Feedback: String, Codable, CaseIterable, Identifiable {
        case silent
        case vibration
        case tones

        var id: Self { self }

        var title: String {
            switch self {
            case .silent: "Lydløs"
            case .vibration: "Vibration"
            case .tones: "Biptoner"
            }
        }
    }

    var startCountdownSeconds = 10
    var feedback = Feedback.tones
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
        configuration.durationWithoutWarmup + startCountdownSeconds
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
            let repetitions = (1...configuration.repetitions).flatMap { repetition in
                let work = WorkoutStep(
                    phase: .work,
                    duration: configuration.workSeconds,
                    repetition: repetition,
                    round: round
                )
                let rest = repetition < configuration.repetitions && configuration.restSeconds > 0
                    ? [WorkoutStep(
                        phase: .rest,
                        duration: configuration.restSeconds,
                        repetition: repetition,
                        round: round
                    )]
                    : []
                return [work] + rest
            }

            let roundRest = round < configuration.rounds && configuration.roundRestSeconds > 0
                ? [WorkoutStep(
                    phase: .roundRest,
                    duration: configuration.roundRestSeconds,
                    repetition: configuration.repetitions,
                    round: round
                )]
                : []
            return repetitions + roundRest
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
