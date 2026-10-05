import ActivityKit
import SwiftUI
import WidgetKit

struct WorkoutLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            WorkoutLiveActivityContent(
                repetitions: context.attributes.repetitions,
                rounds: context.attributes.rounds,
                endsAt: context.state.endsAt,
                remainingSeconds: context.state.remainingSeconds,
                isPaused: context.state.isPaused,
                isStale: context.isStale
            )
            .activityBackgroundTint(Color.orange.opacity(0.16))
            .activitySystemActionForegroundColor(.orange)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Træning", systemImage: "figure.run")
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    countdown(context)
                        .font(.headline.monospacedDigit())
                        .fixedSize(horizontal: true, vertical: false)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("\(context.attributes.rounds) runder · \(context.attributes.repetitions) gentagelser")
                        .font(.caption)
                }
            } compactLeading: {
                Image(systemName: "figure.run")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                countdown(context)
                    .monospacedDigit()
                    .frame(width: 48, alignment: .trailing)
            } minimal: {
                Image(systemName: "figure.run")
                    .foregroundStyle(.orange)
            }
        }
    }

    @ViewBuilder
    private func countdown(_ context: ActivityViewContext<WorkoutActivityAttributes>) -> some View {
        if context.isStale {
            Text("Færdig")
        } else if context.state.isPaused {
            Text(timerText(context.state.remainingSeconds))
        } else {
            Text(
                timerInterval: context.state.endsAt.addingTimeInterval(
                    -TimeInterval(max(context.state.remainingSeconds, 1))
                )...context.state.endsAt,
                countsDown: true
            )
        }
    }

    private func timerText(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
