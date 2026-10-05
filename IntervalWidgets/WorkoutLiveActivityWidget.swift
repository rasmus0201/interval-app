import ActivityKit
import SwiftUI
import WidgetKit

struct WorkoutLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Label(phaseTitle(context.state.phase), systemImage: phaseSymbol(context.state.phase))
                        .font(.headline)
                    Text(detailText(context))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                countdown(context.state)
                    .font(.title.bold().monospacedDigit())
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.leading, 16)
            .padding(.trailing, 20)
            .padding(.vertical, 16)
            .activityBackgroundTint(phaseColor(context.state.phase).opacity(0.18))
            .activitySystemActionForegroundColor(phaseColor(context.state.phase))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(phaseTitle(context.state.phase), systemImage: phaseSymbol(context.state.phase))
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    countdown(context.state)
                        .font(.headline.monospacedDigit())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(detailText(context))
                        .font(.caption)
                }
            } compactLeading: {
                Image(systemName: phaseSymbol(context.state.phase))
                    .foregroundStyle(phaseColor(context.state.phase))
            } compactTrailing: {
                countdown(context.state)
                    .monospacedDigit()
                    .frame(width: 48, alignment: .trailing)
            } minimal: {
                Image(systemName: phaseSymbol(context.state.phase))
                    .foregroundStyle(phaseColor(context.state.phase))
            }
        }
    }

    @ViewBuilder
    private func countdown(_ state: WorkoutActivityAttributes.ContentState) -> some View {
        if state.isPaused {
            Text(timerText(state.remainingSeconds))
        } else {
            Text(timerInterval: Date.now...max(state.endsAt, Date.now), countsDown: true)
        }
    }

    private func phaseTitle(_ phase: String) -> String {
        switch phase {
        case "warmup": "Gør klar"
        case "work": "Arbejde"
        case "rest": "Hvile"
        case "roundRest": "Rundepause"
        default: "Interval"
        }
    }

    private func phaseSymbol(_ phase: String) -> String {
        switch phase {
        case "warmup": "figure.run"
        case "work": "bolt.fill"
        case "rest": "pause.fill"
        case "roundRest": "arrow.trianglehead.2.clockwise.rotate.90"
        default: "timer"
        }
    }

    private func phaseColor(_ phase: String) -> Color {
        switch phase {
        case "warmup": .indigo
        case "work": .orange
        case "rest": .blue
        case "roundRest": .teal
        default: .orange
        }
    }

    private func detailText(_ context: ActivityViewContext<WorkoutActivityAttributes>) -> String {
        if context.state.phase == "warmup" {
            return "Læg telefonen i lommen"
        }
        return "Runde \(context.state.round) / \(context.attributes.rounds) · Gentagelse \(context.state.repetition) / \(context.attributes.repetitions)"
    }

    private func timerText(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
