import Foundation
import UserNotifications

actor NotificationScheduler {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()
    private let identifierPrefix = "interval.workout."

    func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
    }

    func schedule(
        steps: [WorkoutStep],
        elapsedSeconds: TimeInterval,
        settings: AppSettings
    ) async {
        await cancel()
        guard settings.feedback != .silent else { return }

        var boundary = 0.0
        for (index, step) in steps.enumerated() {
            boundary += TimeInterval(step.duration)
            guard boundary > elapsedSeconds, index + 1 < steps.count else { continue }
            let next = steps[index + 1]
            let delay = boundary - elapsedSeconds
            guard delay >= 1 else { continue }

            let content = UNMutableNotificationContent()
            content.title = next.phase.title
            content.body = statusText(for: next)
            content.sound = sound(
                from: step.phase,
                to: next.phase,
                feedback: settings.feedback
            )

            let request = UNNotificationRequest(
                identifier: identifierPrefix + UUID().uuidString,
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            )
            try? await center.add(request)
        }

        let totalDuration = steps.reduce(0) { $0 + $1.duration }
        let completionDelay = TimeInterval(totalDuration) - elapsedSeconds
        if completionDelay >= 1 {
            let content = UNMutableNotificationContent()
            content.title = "Træning gennemført"
            content.body = "Godt arbejde. Din træning er gemt i historikken."
            content.sound = customSound(named: "complete-signal", feedback: settings.feedback)
            let request = UNNotificationRequest(
                identifier: identifierPrefix + "complete",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: completionDelay, repeats: false)
            )
            try? await center.add(request)
        }
    }

    func cancel() async {
        let requests = await center.pendingNotificationRequests()
        let identifiers = requests
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func statusText(for step: WorkoutStep) -> String {
        switch step.phase {
        case .warmup:
            return "Gør dig klar til træningen."
        case .work, .rest:
            return "Runde \(step.round) · Gentagelse \(step.repetition)"
        case .roundRest:
            return "Runde \(step.round) er færdig."
        }
    }

    private func sound(
        from currentPhase: WorkoutPhase,
        to nextPhase: WorkoutPhase,
        feedback: AppSettings.Feedback
    ) -> UNNotificationSound? {
        switch nextPhase {
        case .work where currentPhase == .rest || currentPhase == .roundRest:
            return customSound(named: "rest-end-signal", feedback: feedback)
        case .work:
            return customSound(named: "start-signal", feedback: feedback)
        case .rest, .roundRest:
            return customSound(named: "work-end-signal", feedback: feedback)
        case .warmup:
            return customSound(named: "blop", feedback: feedback)
        }
    }

    private func customSound(named name: String, feedback: AppSettings.Feedback) -> UNNotificationSound? {
        switch feedback {
        case .silent:
            return nil
        case .vibration:
            return UNNotificationSound(named: UNNotificationSoundName("silence.wav"))
        case .tones:
            return UNNotificationSound(named: UNNotificationSoundName("\(name).wav"))
        }
    }
}
