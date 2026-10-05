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
                        title: "Arbejde",
                        seconds: $store.configuration.workSeconds,
                        minimumSeconds: 1
                    )
                    DurationLink(
                        title: "Hvile",
                        seconds: $store.configuration.restSeconds,
                        minimumSeconds: 0
                    )
                }

                Section {
                    Stepper(value: $store.configuration.repetitions, in: 1...99) {
                        valueRow(title: "Gentagelser", value: "\(store.configuration.repetitions)")
                    }
                    Stepper(value: $store.configuration.rounds, in: 1...50) {
                        valueRow(title: "Runder", value: "\(store.configuration.rounds)")
                    }
                }

                Section {
                    DurationLink(
                        title: "Rundepause",
                        seconds: $store.configuration.roundRestSeconds,
                        minimumSeconds: 0
                    )
                } footer: {
                    Text(workoutSummary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("Træning")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Indstillinger", systemImage: "gearshape") {
                        showsSettings = true
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: onStart) {
                    Text("Start træning")
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

    private var workoutSummary: String {
        let duration = store.configuration.durationWithoutWarmup + store.settings.startCountdownSeconds
        return "\(duration.shortDurationText) · \(store.configuration.workIntervalCount) arbejdsintervaller"
    }

    private func valueRow(title: String, value: String) -> some View {
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

    let title: String
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
