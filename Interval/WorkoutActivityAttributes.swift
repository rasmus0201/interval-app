import ActivityKit
import Foundation

struct WorkoutActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let phase: String
        let endsAt: Date
        let remainingSeconds: Int
        let repetition: Int
        let round: Int
        let isPaused: Bool
    }

    let repetitions: Int
    let rounds: Int
}

// Lives here because this file is compiled into both the app and the widget.
extension Int {
    var roundCountText: String {
        String(localized: "\(self) rounds")
    }

    var repetitionCountText: String {
        String(localized: "\(self) reps")
    }
}
