import SwiftUI

struct WorkoutSetupView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var showsSettings = false

    let onStart: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DurationLink(
                        title: "Work",
                        seconds: $store.configuration.workSeconds,
                        minimumSeconds: 1
                    )
                    DurationLink(
                        title: "Rest",
                        seconds: $store.configuration.restSeconds,
                        minimumSeconds: 0
                    )
                }

                Section {
                    Stepper(value: $store.configuration.repetitions, in: 1...99) {
                        valueRow(title: "Reps", value: "\(store.configuration.repetitions)")
                    }
                    Stepper(value: $store.configuration.rounds, in: 1...50) {
                        valueRow(title: "Rounds", value: "\(store.configuration.rounds)")
                    }
                } footer: {
                    Text("All reps in a round run before the rest between rounds.")
                }

                Section {
                    DurationLink(
                        title: "Extra round break",
                        seconds: $store.configuration.roundRestSeconds,
                        minimumSeconds: 0
                    )
                } footer: {
                    VStack(spacing: 6) {
                        Text("Added to the rest between rounds.")
                        Text(store.configuration.summaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("Workout")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gearshape") {
                        showsSettings = true
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: onStart) {
                    Text("Start workout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.bar)
            }
            .sheet(isPresented: $showsSettings) {
                SettingsView()
            }
        }
    }

    private func valueRow(title: LocalizedStringKey, value: String) -> some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    Text(value)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            } else {
                HStack {
                    Text(title)
                    Spacer()
                    Text(value)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
    }
}

private struct DurationLink: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: LocalizedStringKey
    @Binding var seconds: Int
    let minimumSeconds: Int

    var body: some View {
        NavigationLink {
            DurationPickerView(
                title: title,
                seconds: $seconds,
                minimumSeconds: minimumSeconds
            )
        } label: {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    Text(seconds.timerText)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            } else {
                HStack {
                    Text(title)
                    Spacer()
                    Text(seconds.timerText)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .accessibilityValue(seconds.shortDurationText)
    }
}
