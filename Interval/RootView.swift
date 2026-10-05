import SwiftUI

struct RootView: View {
    private enum Tab: Hashable {
        case workout
        case history
    }

    @EnvironmentObject private var store: AppStore
    @State private var selectedTab = Tab.workout
    @State private var session: WorkoutSession?

    var body: some View {
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
    }
}

private struct WorkoutSession: Identifiable {
    let id = UUID()
    let configuration: WorkoutConfiguration
    let settings: AppSettings
}
