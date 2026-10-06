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
    func counted(_ singular: String, _ plural: String) -> String {
        "\(self) \(self == 1 ? singular : plural)"
    }
}
