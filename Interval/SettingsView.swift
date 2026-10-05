import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore

    private let countdownOptions = [0, 10, 30, 60]

    var body: some View {
        NavigationStack {
            Form {
                Section("Opvarmningstid") {
                    Picker("Start-countdown", selection: $store.settings.startCountdownSeconds) {
                        ForEach(countdownOptions, id: \.self) { seconds in
                            Text(seconds == 0 ? "Fra" : "\(seconds) sek").tag(seconds)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Toggle("Biplyde", isOn: $store.settings.tonesEnabled)

                    if store.settings.tonesEnabled {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Lydstyrke")
                                Spacer()
                                Text(store.settings.cueVolume, format: .percent.precision(.fractionLength(0)))
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                            Slider(value: $store.settings.cueVolume, in: 0...1, step: 0.05)
                                .accessibilityLabel("Lydstyrke")
                        }
                    }
                } header: {
                    Text("Lyd")
                } footer: {
                    Text("100 % bruger telefonens fulde medielydstyrke. Biptoner afspilles også, når telefonen er låst eller på lydløs.")
                }

                Section("Vibration") {
                    Toggle("Vibration", isOn: $store.settings.vibrationEnabled)
                }
            }
            .navigationTitle("Indstillinger")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Færdig") { dismiss() }
                }
            }
        }
    }
}
