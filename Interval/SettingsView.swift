import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore

    private let countdownOptions = [0, 10, 30, 60]

    var body: some View {
        NavigationStack {
            Form {
                Section("Warm-up") {
                    Picker("Start countdown", selection: $store.settings.startCountdownSeconds) {
                        ForEach(countdownOptions, id: \.self) { seconds in
                            Text(seconds == 0 ? String(localized: "Off") : seconds.shortDurationText).tag(seconds)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Toggle("Beeps", isOn: $store.settings.tonesEnabled)

                    if store.settings.tonesEnabled {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Volume")
                                Spacer()
                                Text(store.settings.cueVolume, format: .percent.precision(.fractionLength(0)))
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                            Slider(value: $store.settings.cueVolume, in: 0...1, step: 0.05)
                                .accessibilityLabel("Volume")
                        }
                    }
                } header: {
                    Text("Sound")
                } footer: {
                    Text("At 100%, beeps use the phone's full media volume. They also play when the phone is locked or on silent.")
                }

                Section("Vibration") {
                    Toggle("Vibration", isOn: $store.settings.vibrationEnabled)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
