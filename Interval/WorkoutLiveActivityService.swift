import ActivityKit
import Foundation

@MainActor
final class WorkoutLiveActivityService {
    static let shared = WorkoutLiveActivityService()

    private var activity: Activity<WorkoutActivityAttributes>?
    private var startTask: Task<Void, Never>?

    func start(configuration: WorkoutConfiguration, remainingSeconds: Int) {
        let previousStartTask = startTask
        startTask = Task {
            await previousStartTask?.value
            await endActiveActivities()
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

            let attributes = WorkoutActivityAttributes(
                repetitions: configuration.repetitions,
                rounds: configuration.rounds
            )
            let content = ActivityContent(
                state: state(remainingSeconds: remainingSeconds, isPaused: false),
                staleDate: Date.now.addingTimeInterval(TimeInterval(remainingSeconds)),
                relevanceScore: 100
            )
            activity = try? Activity.request(attributes: attributes, content: content)
        }
    }

    func update(remainingSeconds: Int, isPaused: Bool) {
        let content = ActivityContent(
            state: state(remainingSeconds: remainingSeconds, isPaused: isPaused),
            staleDate: isPaused ? nil : Date.now.addingTimeInterval(TimeInterval(remainingSeconds)),
            relevanceScore: 100
        )
        let pendingStart = startTask
        Task {
            await pendingStart?.value
            guard let activeActivity else { return }
            await activeActivity.update(content)
            activity = activeActivity
        }
    }

    func end() async {
        let pendingStart = startTask
        startTask = nil
        await pendingStart?.value
        await endActiveActivities()
    }

    private func state(
        remainingSeconds: Int,
        isPaused: Bool
    ) -> WorkoutActivityAttributes.ContentState {
        WorkoutActivityAttributes.ContentState(
            phase: "workout",
            endsAt: Date.now.addingTimeInterval(TimeInterval(remainingSeconds)),
            remainingSeconds: remainingSeconds,
            repetition: 0,
            round: 0,
            isPaused: isPaused
        )
    }

    private var activeActivity: Activity<WorkoutActivityAttributes>? {
        if let activity, activity.activityState == .active || activity.activityState == .stale {
            return activity
        }
        return Activity<WorkoutActivityAttributes>.activities.first {
            $0.activityState == .active || $0.activityState == .stale
        }
    }

    private func endActiveActivities() async {
        let activities = Activity<WorkoutActivityAttributes>.activities
        for activity in activities {
            let finalContent = ActivityContent(
                state: activity.content.state,
                staleDate: nil,
                relevanceScore: 0
            )
            await activity.end(finalContent, dismissalPolicy: .immediate)
        }
        activity = nil
    }
}
