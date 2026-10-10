import XCTest
@testable import Interval

final class SpokenCueTests: XCTestCase {
    private let configuration = WorkoutConfiguration(
        workSeconds: 30,
        restSeconds: 20,
        repetitions: 2,
        rounds: 3,
        roundRestSeconds: 0
    )

    private func tracker(
        configuration: WorkoutConfiguration? = nil,
        startCountdownSeconds: Int = 10,
        isEnabled: Bool = true
    ) -> SpokenCueTracker {
        let configuration = configuration ?? self.configuration
        return SpokenCueTracker(
            steps: WorkoutTimeline.steps(
                configuration: configuration,
                startCountdownSeconds: startCountdownSeconds
            ),
            rounds: configuration.rounds,
            isEnabled: isEnabled
        )
    }

    func testAnnouncesPhaseTransitionsAndNewRounds() {
        var cues = tracker()
        // Steps: warmup, work, work, rest, work, work, rest, work, work.
        XCTAssertEqual(cues.cue(stepIndex: 0, remainingSeconds: 10), .getReady)
        XCTAssertEqual(cues.cue(stepIndex: 1, remainingSeconds: 30), .work)
        XCTAssertNil(cues.cue(stepIndex: 2, remainingSeconds: 30))
        XCTAssertEqual(cues.cue(stepIndex: 3, remainingSeconds: 20), .rest)
        XCTAssertEqual(cues.cue(stepIndex: 4, remainingSeconds: 30), .round(2, of: 3))
        XCTAssertEqual(cues.completionCue(), .complete)
    }

    func testAnnouncesRoundBreakWhenRoundsHaveExtraPause() {
        var configuration = configuration
        configuration.roundRestSeconds = 30
        var cues = tracker(configuration: configuration, startCountdownSeconds: 0)

        // Steps: work, work, round break, work, ...
        XCTAssertEqual(cues.cue(stepIndex: 2, remainingSeconds: 50), .roundBreak)
    }

    func testSpeaksNothingWhenDisabled() {
        var cues = tracker(isEnabled: false)

        XCTAssertNil(cues.cue(stepIndex: 0, remainingSeconds: 10))
        XCTAssertNil(cues.cue(stepIndex: 1, remainingSeconds: 30))
        XCTAssertNil(cues.cue(stepIndex: 1, remainingSeconds: 10))
        XCTAssertNil(cues.completionCue())
    }

    func testWarnsOnceAtTenSecondsInLongEnoughPhases() {
        var cues = tracker()
        _ = cues.cue(stepIndex: 1, remainingSeconds: 30)

        XCTAssertNil(cues.cue(stepIndex: 1, remainingSeconds: 11))
        XCTAssertEqual(cues.cue(stepIndex: 1, remainingSeconds: 10), .tenSecondsRemaining)
        // Ten timer ticks per second all report ten seconds remaining.
        XCTAssertNil(cues.cue(stepIndex: 1, remainingSeconds: 10))
        XCTAssertNil(cues.cue(stepIndex: 1, remainingSeconds: 9))
    }

    func testSkipsWarningForShortPhases() {
        var cues = tracker()
        // A 10-second start countdown is too short to warn.
        _ = cues.cue(stepIndex: 0, remainingSeconds: 10)
        XCTAssertNil(cues.cue(stepIndex: 0, remainingSeconds: 10))

        var shortWork = configuration
        shortWork.workSeconds = 15
        var shortCues = tracker(configuration: shortWork, startCountdownSeconds: 0)
        _ = shortCues.cue(stepIndex: 0, remainingSeconds: 15)
        XCTAssertNil(shortCues.cue(stepIndex: 0, remainingSeconds: 10))
    }

    func testPauseAndResumeDoNotRepeatCues() {
        var cues = tracker()
        _ = cues.cue(stepIndex: 1, remainingSeconds: 30)
        _ = cues.cue(stepIndex: 1, remainingSeconds: 10)

        // Resuming synchronizes the same step and time again.
        XCTAssertNil(cues.cue(stepIndex: 1, remainingSeconds: 10))
        XCTAssertNil(cues.cue(stepIndex: 1, remainingSeconds: 30))
    }

    func testCatchingUpAnnouncesOnlyTheCurrentStepWithoutLateWarning() {
        var cues = tracker()
        _ = cues.cue(stepIndex: 1, remainingSeconds: 30)

        // Returning from the background lands late in round 2's first work step.
        XCTAssertEqual(cues.cue(stepIndex: 4, remainingSeconds: 7), .round(2, of: 3))
        XCTAssertNil(cues.cue(stepIndex: 4, remainingSeconds: 7))
        XCTAssertNil(cues.cue(stepIndex: 4, remainingSeconds: 10))
    }

    func testSkipAnnouncesTheNextStep() {
        var cues = tracker()
        _ = cues.cue(stepIndex: 1, remainingSeconds: 25)

        XCTAssertNil(cues.cue(stepIndex: 2, remainingSeconds: 30))
        XCTAssertEqual(cues.cue(stepIndex: 3, remainingSeconds: 20), .rest)
    }

    func testResetAnnouncesTheFirstStepAgain() {
        var cues = tracker()
        _ = cues.cue(stepIndex: 0, remainingSeconds: 10)
        _ = cues.cue(stepIndex: 1, remainingSeconds: 10)
        _ = cues.completionCue()

        cues.reset()

        XCTAssertEqual(cues.cue(stepIndex: 0, remainingSeconds: 10), .getReady)
        XCTAssertEqual(cues.cue(stepIndex: 1, remainingSeconds: 30), .work)
        XCTAssertEqual(cues.cue(stepIndex: 1, remainingSeconds: 10), .tenSecondsRemaining)
        XCTAssertEqual(cues.completionCue(), .complete)
    }

    func testCompletionIsAnnouncedOnce() {
        var cues = tracker()

        XCTAssertEqual(cues.completionCue(), .complete)
        XCTAssertNil(cues.completionCue())
    }

    func testOnlyPhaseCuesWaitForTheTone() {
        XCTAssertTrue(SpokenCue.work.followsPhaseTone)
        XCTAssertTrue(SpokenCue.round(2, of: 3).followsPhaseTone)
        XCTAssertTrue(SpokenCue.complete.followsPhaseTone)
        XCTAssertFalse(SpokenCue.getReady.followsPhaseTone)
        XCTAssertFalse(SpokenCue.tenSecondsRemaining.followsPhaseTone)
    }

    func testSpeechLanguageMatchesTheAppLanguage() {
        XCTAssertEqual(SpeechLanguage.code(localization: "da", systemLanguageCode: "en-GB"), "da-DK")
        XCTAssertEqual(SpeechLanguage.code(localization: "en", systemLanguageCode: "en-GB"), "en-GB")
        XCTAssertEqual(SpeechLanguage.code(localization: "en", systemLanguageCode: "da-DK"), "en-US")
        XCTAssertEqual(SpeechLanguage.code(localization: "da", systemLanguageCode: "da-DK"), "da-DK")
    }

    func testSpokenTextIsTranslatedForBothLanguages() throws {
        let appBundle = Bundle(for: AppStore.self)
        func phrase(_ key: String, _ language: String) throws -> String {
            let path = try XCTUnwrap(appBundle.path(forResource: language, ofType: "lproj"))
            return try XCTUnwrap(Bundle(path: path)).localizedString(forKey: key, value: nil, table: nil)
        }

        XCTAssertEqual(try phrase("spoken.round", "en"), "Round %1$lld of %2$lld")
        XCTAssertEqual(try phrase("spoken.round", "da"), "Runde %1$lld af %2$lld")
        XCTAssertEqual(try phrase("spoken.getReady", "da"), "Gør dig klar")
        XCTAssertEqual(try phrase("spoken.complete", "en"), "Workout complete")
        XCTAssertEqual(try phrase("spoken.complete", "da"), "Træningen er færdig")
    }

    @MainActor
    func testSpokenCuesSettingPersistsAndDefaultsToOff() {
        let suiteName = "SpokenCueTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = AppStore(defaults: defaults)
        XCTAssertFalse(store.settings.spokenCuesEnabled)

        store.settings.spokenCuesEnabled = true

        XCTAssertTrue(AppStore(defaults: defaults).settings.spokenCuesEnabled)
    }

    @MainActor
    func testLegacySettingsLoadWithSpokenCuesOff() throws {
        let suiteName = "SpokenCueTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let legacySettings = try JSONSerialization.data(withJSONObject: [
            "startCountdownSeconds": 30,
            "feedback": "tonesAndVibration",
            "cueVolume": 0.5
        ])
        defaults.set(legacySettings, forKey: "appSettings")

        let settings = AppStore(defaults: defaults).settings

        XCTAssertEqual(settings.startCountdownSeconds, 30)
        XCTAssertEqual(settings.feedback, .tonesAndVibration)
        XCTAssertEqual(settings.cueVolume, 0.5)
        XCTAssertFalse(settings.spokenCuesEnabled)
    }
}
