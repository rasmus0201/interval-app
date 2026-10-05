import SwiftUI
import UIKit

@MainActor
final class WorkoutEngine: ObservableObject {
    @Published private(set) var stepIndex = 0
    @Published private(set) var remainingSeconds = 0
    @Published private(set) var isPaused = false
    @Published private(set) var isFinished = false

    let configuration: WorkoutConfiguration
    let settings: AppSettings
    let steps: [WorkoutStep]

    private var timer: Timer?
    private var anchorDate: Date?
    private var pausedElapsed: TimeInterval = 0
    private var didStart = false
    private var didComplete = false
    private var lastCountdownCue: Int?

    init(configuration: WorkoutConfiguration, settings: AppSettings) {
        self.configuration = configuration
        self.settings = settings
        steps = WorkoutTimeline.steps(
            configuration: configuration,
            startCountdownSeconds: settings.startCountdownSeconds
        )
        remainingSeconds = steps.first?.duration ?? 0
    }

    var currentStep: WorkoutStep {
        steps[min(stepIndex, max(steps.count - 1, 0))]
    }

    var progress: Double {
        guard !steps.isEmpty else { return 0 }
        let completed = steps.prefix(stepIndex).reduce(0) { $0 + $1.duration }
        let currentElapsed = currentStep.duration - remainingSeconds
        return min(1, Double(completed + currentElapsed) / Double(totalDuration))
    }

    var totalDuration: Int {
        steps.reduce(0) { $0 + $1.duration }
    }

    var remainingDuration: Int {
        remainingSeconds + steps.dropFirst(stepIndex + 1).reduce(0) { $0 + $1.duration }
    }

    func start() {
        guard !didStart, !steps.isEmpty else { return }
        didStart = true
        anchorDate = .now
        UIApplication.shared.isIdleTimerDisabled = true
        AudioCueService.shared.prepare()
        playTransitionCue(for: currentStep.phase, previousPhase: nil)
        WorkoutLiveActivityService.shared.start(
            configuration: configuration,
            remainingSeconds: remainingDuration
        )
        startTimer()

    }

    func togglePause() {
        if isPaused {
            anchorDate = Date().addingTimeInterval(-pausedElapsed)
            isPaused = false
            WorkoutLiveActivityService.shared.update(
                remainingSeconds: remainingDuration,
                isPaused: false
            )
            startTimer()
        } else {
            pausedElapsed = elapsedSeconds
            isPaused = true
            stopTimer()
            WorkoutLiveActivityService.shared.update(
                remainingSeconds: remainingDuration,
                isPaused: true
            )
        }
    }

    func skip() {
        guard !isFinished else { return }
        let nextElapsed = TimeInterval(steps.prefix(stepIndex + 1).reduce(0) { $0 + $1.duration })
        if isPaused {
            pausedElapsed = nextElapsed
        } else {
            anchorDate = Date().addingTimeInterval(-nextElapsed)
        }
        synchronize(elapsed: nextElapsed)
        WorkoutLiveActivityService.shared.update(
            remainingSeconds: remainingDuration,
            isPaused: isPaused
        )
    }

    func stop() {
        stopTimer()
        UIApplication.shared.isIdleTimerDisabled = false
        AudioCueService.shared.stop()
        Task { await WorkoutLiveActivityService.shared.end() }
    }

    func reset() {
        guard !steps.isEmpty else { return }
        stopTimer()
        stepIndex = 0
        remainingSeconds = steps[0].duration
        isPaused = false
        isFinished = false
        didComplete = false
        pausedElapsed = 0
        anchorDate = .now
        lastCountdownCue = nil
        playTransitionCue(for: steps[0].phase, previousPhase: nil)
        WorkoutLiveActivityService.shared.update(
            remainingSeconds: remainingDuration,
            isPaused: false
        )
        startTimer()
    }

    private var elapsedSeconds: TimeInterval {
        if isPaused {
            return pausedElapsed
        }
        guard let anchorDate else { return 0 }
        return Date().timeIntervalSince(anchorDate)
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        synchronize(elapsed: elapsedSeconds)
    }

    private func synchronize(elapsed: TimeInterval) {
        guard !didComplete else { return }
        if elapsed >= TimeInterval(totalDuration) {
            complete()
            return
        }

        var boundary = 0.0
        let newIndex = steps.firstIndex { step in
            boundary += TimeInterval(step.duration)
            return elapsed < boundary
        } ?? steps.count - 1
        let stepStart = steps.prefix(newIndex).reduce(0) { $0 + $1.duration }
        let newRemaining = max(0, Int(ceil(Double(steps[newIndex].duration) - (elapsed - Double(stepStart)))))

        if newIndex != stepIndex {
            let previousPhase = steps[stepIndex].phase
            stepIndex = newIndex
            lastCountdownCue = nil
            playTransitionCue(for: steps[newIndex].phase, previousPhase: previousPhase)
        }
        remainingSeconds = newRemaining

        if newRemaining <= 3, newRemaining > 0, lastCountdownCue != newRemaining {
            lastCountdownCue = newRemaining
            play(.blop)
        }
    }

    private func playTransitionCue(for phase: WorkoutPhase, previousPhase: WorkoutPhase?) {
        switch phase {
        case .warmup:
            play(.blop)
        case .work where previousPhase == .rest || previousPhase == .roundRest:
            play(.restEnded)
        case .work:
            play(.start)
        case .rest, .roundRest:
            play(.workEnded)
        }
    }

    private func play(_ cue: AudioCueService.Cue) {
        AudioCueService.shared.play(
            cue,
            feedback: settings.feedback,
            volume: settings.cueVolume
        )
    }

    private func complete() {
        didComplete = true
        isFinished = true
        remainingSeconds = 0
        stopTimer()
        UIApplication.shared.isIdleTimerDisabled = false
        play(.complete)
        Task { await WorkoutLiveActivityService.shared.end() }
    }
}
