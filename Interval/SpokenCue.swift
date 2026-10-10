import Foundation

enum SpokenCue: Equatable {
    case getReady
    case work
    case round(Int, of: Int)
    case rest
    case roundBreak
    case tenSecondsRemaining
    case complete

    var text: String {
        switch self {
        case .getReady:
            String(localized: "spoken.getReady", defaultValue: "Get ready")
        case .work:
            String(localized: "spoken.work", defaultValue: "Work")
        case let .round(round, total):
            String(localized: "spoken.round", defaultValue: "Round \(round) of \(total)")
        case .rest:
            String(localized: "spoken.rest", defaultValue: "Rest")
        case .roundBreak:
            String(localized: "spoken.roundBreak", defaultValue: "Round break")
        case .tenSecondsRemaining:
            String(localized: "spoken.tenSecondsRemaining", defaultValue: "10 seconds remaining")
        case .complete:
            String(localized: "spoken.complete", defaultValue: "Workout complete")
        }
    }

    /// Cues that coincide with a phase tone wait for the tone before speaking.
    var followsPhaseTone: Bool {
        switch self {
        case .getReady, .tenSecondsRemaining: false
        case .work, .round, .rest, .roundBreak, .complete: true
        }
    }
}

/// Decides when a spoken cue is due, separately from playing it.
/// Each step is announced once and warned at most once, so repeated timer
/// ticks, pause and resume, or catching up after the background never repeat a cue.
struct SpokenCueTracker {
    static let warningSeconds = 10
    static let minimumWarnedDuration = 20

    private let steps: [WorkoutStep]
    private let rounds: Int
    private let isEnabled: Bool
    private var announcedStepIndex: Int?
    private var warnedStepIndex: Int?
    private var didAnnounceCompletion = false

    init(steps: [WorkoutStep], rounds: Int, isEnabled: Bool) {
        self.steps = steps
        self.rounds = rounds
        self.isEnabled = isEnabled
    }

    mutating func cue(stepIndex: Int, remainingSeconds: Int) -> SpokenCue? {
        guard isEnabled, steps.indices.contains(stepIndex) else { return nil }
        let step = steps[stepIndex]

        if announcedStepIndex != stepIndex {
            announcedStepIndex = stepIndex
            if remainingSeconds <= Self.warningSeconds {
                warnedStepIndex = stepIndex
            }
            return transitionCue(for: step)
        }

        guard remainingSeconds == Self.warningSeconds,
              step.duration >= Self.minimumWarnedDuration,
              warnedStepIndex != stepIndex else { return nil }
        warnedStepIndex = stepIndex
        return .tenSecondsRemaining
    }

    mutating func completionCue() -> SpokenCue? {
        guard isEnabled, !didAnnounceCompletion else { return nil }
        didAnnounceCompletion = true
        return .complete
    }

    mutating func reset() {
        announcedStepIndex = nil
        warnedStepIndex = nil
        didAnnounceCompletion = false
    }

    private func transitionCue(for step: WorkoutStep) -> SpokenCue? {
        switch step.phase {
        case .warmup:
            return .getReady
        case .work:
            guard step.repetition == 1 else { return nil }
            return step.round > 1 ? .round(step.round, of: rounds) : .work
        case .rest:
            return .rest
        case .roundRest:
            return .roundBreak
        }
    }
}
