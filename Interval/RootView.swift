import SwiftUI

struct RootView: View {
    private enum Tab: Hashable {
        case workout
        case history
    }

    @EnvironmentObject private var store: AppStore
    @State private var selectedTab = Tab.workout
    @State private var session: WorkoutSession?
#if DEBUG
    @State private var didStartLiveActivityTest = false
#endif

    var body: some View {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--live-activity-layout-test") {
            LiveActivityLayoutTestView()
        } else {
            appContent
        }
#else
        appContent
#endif
    }

    private var appContent: some View {
        TabView(selection: $selectedTab) {
            WorkoutSetupView {
                session = WorkoutSession(
                    configuration: store.configuration,
                    settings: store.settings
                )
            }
            .tabItem {
                Label("Træning", systemImage: "figure.run")
            }
            .tag(Tab.workout)

            HistoryView { entry in
                store.load(entry)
                selectedTab = .workout
            }
            .tabItem {
                Label("Historik", systemImage: "chart.bar.fill")
            }
            .tag(Tab.history)
        }
        .fullScreenCover(item: $session) { session in
            WorkoutView(
                configuration: session.configuration,
                settings: session.settings
            ) {
                store.addCompletedWorkout(
                    configuration: session.configuration,
                    startCountdownSeconds: session.settings.startCountdownSeconds
                )
            }
        }
#if DEBUG
        .onAppear {
            guard ProcessInfo.processInfo.arguments.contains("--live-activity-test"),
                  !didStartLiveActivityTest else { return }
            didStartLiveActivityTest = true
            session = Self.liveActivityTestSession
        }
#endif
    }

#if DEBUG
    private static var liveActivityTestSession: WorkoutSession {
        let configuration = WorkoutConfiguration(
            workSeconds: 15,
            restSeconds: 10,
            repetitions: 1,
            rounds: 2,
            roundRestSeconds: 0
        )
        var settings = AppSettings()
        settings.startCountdownSeconds = 0
        settings.feedback = .silent
        return WorkoutSession(configuration: configuration, settings: settings)
    }
#endif
}

#if DEBUG
private struct LiveActivityLayoutTestView: View {
    @State private var endsAt = Date.now.addingTimeInterval(83)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.indigo.opacity(0.75), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            WorkoutLiveActivityContent(
                repetitions: 1,
                rounds: 8,
                endsAt: endsAt,
                remainingSeconds: 83,
                isPaused: false,
                isStale: ProcessInfo.processInfo.arguments.contains(
                    "--live-activity-layout-finished-test"
                )
            )
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 16)
        }
    }
}
#endif

private struct WorkoutSession: Identifiable {
    let id = UUID()
    let configuration: WorkoutConfiguration
    let settings: AppSettings
}
