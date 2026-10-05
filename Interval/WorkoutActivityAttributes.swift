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
