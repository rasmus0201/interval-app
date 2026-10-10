import SwiftUI

struct WorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @StateObject private var engine: WorkoutEngine
    @State private var showsStopConfirmation = false
    @State private var completionWasRecorded = false

    private let onComplete: () -> Void

    init(
        configuration: WorkoutConfiguration,
        settings: AppSettings,
        onComplete: @escaping () -> Void
    ) {
        _engine = StateObject(
            wrappedValue: WorkoutEngine(configuration: configuration, settings: settings)
        )
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            phaseColor
                .ignoresSafeArea()
                .animation(reduceMotion ? nil : .easeOut(duration: 0.35), value: engine.stepIndex)

            if engine.isFinished {
                completionView
            } else {
                activeWorkoutView
            }
        }
        .foregroundStyle(.white)
        .onAppear { engine.start() }
        .onDisappear { engine.stop() }
        .onChange(of: engine.isFinished) { _, isFinished in
            guard isFinished, !completionWasRecorded else { return }
            completionWasRecorded = true
            onComplete()
        }
        .alert("Stop the workout?", isPresented: $showsStopConfirmation) {
            Button("Continue", role: .cancel) {}
            Button("Stop", role: .destructive) {
                engine.stop()
                dismiss()
            }
        } message: {
            Text("The workout won't be saved to history.")
        }
    }

    private var activeWorkoutView: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Close", systemImage: "xmark") {
                    showsStopConfirmation = true
                }
                .labelStyle(.iconOnly)
                .font(.title3.weight(.semibold))
                .frame(width: 44, height: 44)

                Spacer()

                if engine.currentStep.phase != .warmup {
                    Text("Round \(engine.currentStep.round) / \(engine.configuration.rounds)")
                        .font(.headline)
                }

                Button("Restart", systemImage: "arrow.counterclockwise") {
                    engine.reset()
                }
                .labelStyle(.iconOnly)
                .font(.title3.weight(.semibold))
                .frame(width: 44, height: 44)
            }
            .padding()

            Spacer()

            Image(systemName: engine.currentStep.phase.symbol)
                .font(.title.weight(.semibold))
                .accessibilityHidden(true)

            Text(engine.currentStep.phase.title.uppercased())
                .font(.headline)
                .tracking(1.5)
                .padding(.top, 12)

            Text(engine.remainingSeconds.timerText)
                .font(.system(size: 92, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.65)
                .contentTransition(.numericText(countsDown: true))
                .animation(reduceMotion ? nil : .snappy, value: engine.remainingSeconds)
                .accessibilityLabel("\(engine.remainingSeconds) seconds remaining")

            if engine.currentStep.phase == .work {
                Text("Rep \(engine.currentStep.repetition) / \(engine.configuration.repetitions)")
                    .font(.title3.weight(.medium))
            } else if engine.currentStep.phase == .warmup {
                Text("Put your phone in your pocket")
                    .font(.title3.weight(.medium))
            } else {
                Text("Next: Round \(min(engine.currentStep.round + 1, engine.configuration.rounds))")
                    .font(.title3.weight(.medium))
            }

            Spacer()

            ProgressView(value: engine.progress)
                .tint(.white)
                .background(.white.opacity(0.25))
                .padding(.horizontal)

            HStack(spacing: 16) {
                Button {
                    engine.togglePause()
                } label: {
                    controlLabel(
                        engine.isPaused ? "Resume" : "Pause",
                        systemImage: engine.isPaused ? "play.fill" : "pause.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(phaseColor)

                Button {
                    engine.skip()
                } label: {
                    controlLabel("Skip", systemImage: "forward.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }
            .font(.headline)
            .padding()
        }
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .accessibilityHidden(true)

            Text("Workout complete")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text(engine.configuration.summaryText)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.85))

            Spacer()

            Button("Done") {
                dismiss()
            }
            .font(.headline)
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.green)
            .controlSize(.large)
            .padding(.bottom)
        }
        .padding()
    }

    private var phaseColor: Color {
        if engine.isFinished { return .green }
        switch engine.currentStep.phase {
        case .warmup: return .indigo
        case .work: return .orange
        case .rest: return .blue
        case .roundRest: return .teal
        }
    }

    @ViewBuilder
    private func controlLabel(_ title: LocalizedStringKey, systemImage: String) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            Image(systemName: systemImage)
                .font(.title2)
                .accessibilityLabel(title)
        } else {
            Label(title, systemImage: systemImage)
        }
    }
}
