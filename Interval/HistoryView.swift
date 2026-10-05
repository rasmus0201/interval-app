import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: AppStore
    let onLoad: (WorkoutHistoryEntry) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if store.history.isEmpty {
                    ContentUnavailableView(
                        "Ingen træninger endnu",
                        systemImage: "figure.run",
                        description: Text("Gennemfør en træning, så vises den her.")
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
                                Button("Indlæs", systemImage: "arrow.down.doc") {
                                    onLoad(entry)
                                }
                                .tint(.orange)
                            }
                        }
                        .onDelete(perform: store.deleteHistory)
                    }
                }
            }
            .navigationTitle("Historik")
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
            Text("\(entry.configuration.workSeconds.timerText) arbejde · \(entry.configuration.restSeconds.timerText) hvile")
                .foregroundStyle(.secondary)
            Text("\(entry.configuration.repetitions) gentagelser · \(entry.configuration.rounds) runder")
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
            Section("Træning") {
                LabeledContent("Arbejde", value: entry.configuration.workSeconds.timerText)
                LabeledContent("Hvile", value: entry.configuration.restSeconds.timerText)
                LabeledContent("Gentagelser", value: "\(entry.configuration.repetitions)")
                LabeledContent("Runder", value: "\(entry.configuration.rounds)")
                LabeledContent("Rundepause", value: entry.configuration.roundRestSeconds.timerText)
            }

            Section {
                Button("Brug disse indstillinger", systemImage: "arrow.down.doc", action: onLoad)
            }
        }
        .navigationTitle(entry.completedAt.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }
}
