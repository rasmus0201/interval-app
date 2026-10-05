import XCTest
@testable import Interval

final class WorkoutTimelineTests: XCTestCase {
    func testBuildsRepetitionsInsideRounds() {
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
            .work, .rest, .work, .rest, .work,
            .roundRest,
            .work, .rest, .work, .rest, .work
        ])
        XCTAssertEqual(steps.reduce(0) { $0 + $1.duration }, 400)
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
}
