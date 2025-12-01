import Foundation

@MainActor
final class StatsViewModel: ObservableObject {
    @Published var sessions: [Session] = []

    private let sessionStore: SessionStore

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
        load()
    }

    func load() {
        sessions = sessionStore.loadSessions().sorted { $0.startedAt > $1.startedAt }
    }
}
