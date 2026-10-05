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
                Label("Træning", systemImage: "figure.run")
                    .font(.headline)
                Text("\(rounds) runder · \(repetitions) gentagelser")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            countdown
                .font(.title.bold().monospacedDigit())
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(height: 68)
    }

    @ViewBuilder
    private var countdown: some View {
        if isStale {
            Text("Færdig")
        } else if isPaused {
            Text(timerText(remainingSeconds))
        } else {
            Text(
                timerInterval: endsAt.addingTimeInterval(
                    -TimeInterval(max(remainingSeconds, 1))
                )...endsAt,
                countsDown: true
            )
        }
    }

    private func timerText(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
