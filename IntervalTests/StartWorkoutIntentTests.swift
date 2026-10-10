import XCTest
@testable import Interval

@MainActor
final class StartWorkoutIntentTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "StartWorkoutIntentTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testStartsTheSavedConfigurationAndSettings() {
        let configuration = WorkoutConfiguration(
            workSeconds: 20,
            restSeconds: 10,
            repetitions: 8,
            rounds: 2,
            roundRestSeconds: 30
        )
        AppStore(defaults: defaults).configuration = configuration
        AppStore(defaults: defaults).settings.spokenCuesEnabled = true
        let store = AppStore(defaults: defaults)

        let session = WorkoutSession.requested(
            activeSession: nil,
            configuration: store.configuration,
            settings: store.settings
        )

        XCTAssertEqual(session?.configuration, configuration)
        XCTAssertEqual(session?.settings.spokenCuesEnabled, true)
    }

    func testFallsBackToTheDefaultConfiguration() {
        let store = AppStore(defaults: defaults)

        let session = WorkoutSession.requested(
            activeSession: nil,
            configuration: store.configuration,
            settings: store.settings
        )

        XCTAssertEqual(session?.configuration, WorkoutConfiguration())
    }

    func testNeverStartsASecondSession() {
        let active = WorkoutSession(configuration: WorkoutConfiguration(), settings: AppSettings())

        let session = WorkoutSession.requested(
            activeSession: active,
            configuration: WorkoutConfiguration(),
            settings: AppSettings()
        )

        XCTAssertNil(session)
    }

    func testRequestIsConsumedOnce() {
        let requests = WorkoutStartRequests()

        XCTAssertFalse(requests.consume())
        requests.request()
        requests.request()
        XCTAssertTrue(requests.consume())
        XCTAssertFalse(requests.consume())
    }

    func testIntentQueuesAStartRequestWithoutStartingATimer() async throws {
        _ = WorkoutStartRequests.shared.consume()

        _ = try await StartWorkoutIntent().perform()

        XCTAssertTrue(WorkoutStartRequests.shared.consume())
        XCTAssertTrue(StartWorkoutIntent.openAppWhenRun)
    }
}
