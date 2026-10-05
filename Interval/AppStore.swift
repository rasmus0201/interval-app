import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published var configuration: WorkoutConfiguration {
        didSet { save(configuration, key: Keys.configuration) }
    }

    @Published var settings: AppSettings {
        didSet { save(settings, key: Keys.settings) }
    }

    @Published private(set) var history: [WorkoutHistoryEntry] {
        didSet { save(history, key: Keys.history) }
    }

    private enum Keys {
        static let configuration = "workoutConfiguration"
        static let settings = "appSettings"
        static let history = "workoutHistory"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        configuration = Self.load(WorkoutConfiguration.self, key: Keys.configuration, defaults: defaults)
            ?? WorkoutConfiguration()
        settings = Self.load(AppSettings.self, key: Keys.settings, defaults: defaults)
            ?? AppSettings()
        history = Self.load([WorkoutHistoryEntry].self, key: Keys.history, defaults: defaults)
            ?? []
    }

    func addCompletedWorkout(configuration: WorkoutConfiguration, startCountdownSeconds: Int) {
        history.insert(
            WorkoutHistoryEntry(
                configuration: configuration,
                startCountdownSeconds: startCountdownSeconds
            ),
            at: 0
        )
    }

    func load(_ entry: WorkoutHistoryEntry) {
        configuration = entry.configuration
    }

    func deleteHistory(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
    }

    private let defaults: UserDefaults

    private func save<Value: Encodable>(_ value: Value, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<Value: Decodable>(
        _ type: Value.Type,
        key: String,
        defaults: UserDefaults
    ) -> Value? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
