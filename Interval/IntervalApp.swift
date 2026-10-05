import SwiftUI

@main
struct IntervalApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .tint(.orange)
        }
    }
}
