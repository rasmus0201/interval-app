import SwiftUI

struct DurationPickerView: View {
    let title: String
    @Binding var seconds: Int
    let minimumSeconds: Int

    private var minutes: Binding<Int> {
        Binding(
            get: { seconds / 60 },
            set: { newMinutes in
                seconds = max(minimumSeconds, newMinutes * 60 + seconds % 60)
            }
        )
    }

    private var remainingSeconds: Binding<Int> {
        Binding(
            get: { seconds % 60 },
            set: { newSeconds in
                seconds = max(minimumSeconds, (seconds / 60) * 60 + newSeconds)
            }
        )
    }

    var body: some View {
        HStack(spacing: 8) {
            Picker("Minutter", selection: minutes) {
                ForEach(0..<60, id: \.self) { minute in
                    Text("\(minute)").tag(minute)
                }
            }
            .pickerStyle(.wheel)

            Text("min")
                .foregroundStyle(.secondary)

            Picker("Sekunder", selection: remainingSeconds) {
                ForEach(0..<60, id: \.self) { second in
                    Text(String(format: "%02d", second)).tag(second)
                }
            }
            .pickerStyle(.wheel)

            Text("sek")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
