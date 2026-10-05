import ActivityKit
import Foundation

@MainActor
final class WorkoutLiveActivityService {
    static let shared = WorkoutLiveActivityService()

    private var activity: Activity<WorkoutActivityAttributes>?

    func start(step: WorkoutStep, configuration: WorkoutConfiguration, remainingSeconds: Int) {
        Task {
            await end()
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

            let attributes = WorkoutActivityAttributes(
                repetitions: configuration.repetitions,
                rounds: configuration.rounds
            )
            let content = ActivityContent(
                state: state(step: step, remainingSeconds: remainingSeconds, isPaused: false),
                staleDate: Date.now.addingTimeInterval(TimeInterval(remainingSeconds + 5))
            )
            activity = try? Activity.request(attributes: attributes, content: content)
        }
    }

    func update(step: WorkoutStep, remainingSeconds: Int, isPaused: Bool) {
        guard let activity else { return }
        let content = ActivityContent(
            state: state(step: step, remainingSeconds: remainingSeconds, isPaused: isPaused),
            staleDate: isPaused ? nil : Date.now.addingTimeInterval(TimeInterval(remainingSeconds + 5))
        )
        Task { await activity.update(content) }
    }

    func end() async {
        guard let activity else { return }
        let finalContent = ActivityContent(
            state: activity.content.state,
            staleDate: nil
        )
        await activity.end(finalContent, dismissalPolicy: .immediate)
        self.activity = nil
    }

    private func state(
        step: WorkoutStep,
        remainingSeconds: Int,
        isPaused: Bool
    ) -> WorkoutActivityAttributes.ContentState {
        WorkoutActivityAttributes.ContentState(
            phase: step.phase.rawValue,
            endsAt: Date.now.addingTimeInterval(TimeInterval(remainingSeconds)),
            remainingSeconds: remainingSeconds,
            repetition: step.repetition,
            round: step.round,
            isPaused: isPaused
        )
    }
}
