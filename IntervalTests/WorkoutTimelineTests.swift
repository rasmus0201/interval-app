import XCTest
@testable import Interval

final class WorkoutTimelineTests: XCTestCase {
    func testBuildsRepetitionsBeforeBreakBetweenRounds() {
        let configuration = WorkoutConfiguration(
            workSeconds: 45,
            restSeconds: 15,
            repetitions: 3,
            rounds: 2,
            roundRestSeconds: 60
        )

        let steps = WorkoutTimeline.steps(configuration: configuration, startCountdownSeconds: 10)

        XCTAssertEqual(steps.map(\.phase), [
            .warmup,
            .work, .work, .work,
            .roundRest,
            .work, .work, .work
        ])
        XCTAssertEqual(steps.reduce(0) { $0 + $1.duration }, 355)
    }

    func testExpectedDurationExcludesStartCountdown() {
        let configuration = WorkoutConfiguration(
            workSeconds: 120,
            restSeconds: 30,
            repetitions: 1,
            rounds: 8,
            roundRestSeconds: 0
        )

        let steps = WorkoutTimeline.steps(configuration: configuration, startCountdownSeconds: 30)
        let historyEntry = WorkoutHistoryEntry(
            configuration: configuration,
            startCountdownSeconds: 30
        )

        XCTAssertEqual(configuration.durationWithoutWarmup, 19 * 60 + 30)
        XCTAssertEqual(historyEntry.totalSeconds, 19 * 60 + 30)
        XCTAssertEqual(steps.reduce(0) { $0 + $1.duration }, 20 * 60)
        XCTAssertEqual(steps.filter { $0.phase == .work }.count, 8)
        XCTAssertEqual(steps.filter { $0.phase == .rest }.count, 7)
        XCTAssertFalse(steps.contains { $0.phase == .roundRest })
    }

    func testOmitsZeroLengthAndTrailingRestSteps() {
        let configuration = WorkoutConfiguration(
            workSeconds: 20,
            restSeconds: 0,
            repetitions: 2,
            rounds: 1,
            roundRestSeconds: 0
        )

        let steps = WorkoutTimeline.steps(configuration: configuration, startCountdownSeconds: 0)

        XCTAssertEqual(steps.map(\.phase), [.work, .work])
        XCTAssertEqual(steps.reduce(0) { $0 + $1.duration }, 40)
    }

    @MainActor
    func testPersistsHistoryAndLoadsItsConfiguration() {
        let suiteName = "WorkoutTimelineTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let configuration = WorkoutConfiguration(
            workSeconds: 30,
            restSeconds: 10,
            repetitions: 5,
            rounds: 4,
            roundRestSeconds: 45
        )
        let store = AppStore(defaults: defaults)

        store.addCompletedWorkout(configuration: configuration, startCountdownSeconds: 30)

        let reloadedStore = AppStore(defaults: defaults)
        XCTAssertEqual(reloadedStore.history.count, 1)
        XCTAssertEqual(reloadedStore.history.first?.configuration, configuration)

        reloadedStore.load(reloadedStore.history[0])
        XCTAssertEqual(reloadedStore.configuration, configuration)
    }

    @MainActor
    func testLoadsSettingsSavedBeforeCueVolumeWasAdded() throws {
        let suiteName = "WorkoutTimelineTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let legacySettings = try JSONSerialization.data(withJSONObject: [
            "startCountdownSeconds": 30,
            "feedback": "vibration"
        ])
        defaults.set(legacySettings, forKey: "appSettings")

        let store = AppStore(defaults: defaults)

        XCTAssertEqual(store.settings.startCountdownSeconds, 30)
        XCTAssertEqual(store.settings.feedback, .vibration)
        XCTAssertEqual(store.settings.cueVolume, 1)
    }
}
