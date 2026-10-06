import SwiftUI

struct WorkoutLiveActivityContent: View {
    let repetitions: Int
    let rounds: Int
    let endsAt: Date
    let remainingSeconds: Int
    let isPaused: Bool
    let isStale: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Image(systemName: "figure.run")
                    Text("Træning")
                }
                .font(.headline)
                Text("\(rounds.counted("runde", "runder")) · \(repetitions.counted("gentagelse", "gentagelser"))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            countdown
                .font(.title.bold().monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: 96, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var countdown: some View {
        if isStale {
            Text("Færdig")
        } else if isPaused {
            Text(timerText(remainingSeconds))
        } else {
            Text(endsAt, style: .timer)
        }
    }

    private func timerText(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
