import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: AppStore
    let onLoad: (WorkoutHistoryEntry) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if store.history.isEmpty {
                    ContentUnavailableView(
                        "No workouts yet",
                        systemImage: "figure.run",
                        description: Text("Finished workouts appear here.")
                    )
                } else {
                    List {
                        ForEach(store.history) { entry in
                            NavigationLink {
                                HistoryDetailView(entry: entry) {
                                    onLoad(entry)
                                }
                            } label: {
                                HistoryRow(entry: entry)
                            }
                            .swipeActions(edge: .leading) {
                                Button("Load", systemImage: "arrow.down.doc") {
                                    onLoad(entry)
                                }
                                .tint(.orange)
                            }
                        }
                        .onDelete(perform: store.deleteHistory)
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

private struct HistoryRow: View {
    let entry: WorkoutHistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.completedAt, format: .dateTime.day().month(.abbreviated).year())
                    .font(.headline)
                Spacer()
                Text(entry.totalSeconds.shortDurationText)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Text("\(entry.configuration.workSeconds.timerText) work · \(entry.configuration.restSeconds.timerText) rest")
                .foregroundStyle(.secondary)
            Text(verbatim: "\(entry.configuration.repetitions.repetitionCountText) · \(entry.configuration.rounds.roundCountText)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct HistoryDetailView: View {
    let entry: WorkoutHistoryEntry
    let onLoad: () -> Void

    var body: some View {
        List {
            Section("Workout") {
                LabeledContent("Work", value: entry.configuration.workSeconds.timerText)
                LabeledContent("Rest", value: entry.configuration.restSeconds.timerText)
                LabeledContent("Reps", value: "\(entry.configuration.repetitions)")
                LabeledContent("Rounds", value: "\(entry.configuration.rounds)")
                LabeledContent("Extra round break", value: entry.configuration.roundRestSeconds.timerText)
            }

            Section {
                Button("Use these settings", systemImage: "arrow.down.doc", action: onLoad)
            }
        }
        .navigationTitle(entry.completedAt.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }
}
