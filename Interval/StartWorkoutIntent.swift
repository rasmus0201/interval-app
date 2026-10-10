import AppIntents
import Foundation

struct StartWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Workout"
    static var description = IntentDescription("Starts a workout with your most recent setup.")
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        WorkoutStartRequests.shared.request()
        return .result()
    }
}

struct KyclaroShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartWorkoutIntent(),
            phrases: [
                "Start my interval workout in \(.applicationName)",
                "Start an interval workout with \(.applicationName)"
            ],
            shortTitle: "Start Workout",
            systemImageName: "figure.run"
        )
    }
}

/// Hands a shortcut's start request to the app's navigation, which owns the workout session.
@MainActor
final class WorkoutStartRequests: ObservableObject {
    static let shared = WorkoutStartRequests()

    @Published private(set) var hasPendingRequest = false

    func request() {
        hasPendingRequest = true
    }

    func consume() -> Bool {
        defer { hasPendingRequest = false }
        return hasPendingRequest
    }
}
