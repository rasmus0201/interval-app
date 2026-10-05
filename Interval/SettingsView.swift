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
                    Picker("Feedback", selection: $store.settings.feedback) {
                        ForEach(AppSettings.Feedback.allCases) { feedback in
                            Text(feedback.title).tag(feedback)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("Træningsfeedback")
                } footer: {
                    Text("Biptoner afspilles også, når telefonen er låst eller på lydløs. Vibration følger enhedens indstillinger.")
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
