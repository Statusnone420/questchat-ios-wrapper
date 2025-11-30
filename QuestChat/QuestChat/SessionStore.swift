import Foundation

protocol SessionStore {
    func loadSessions() -> [Session]
    func saveSessions(_ sessions: [Session])
    func appendSession(_ session: Session)
}

final class UserDefaultsSessionStore: SessionStore {
    private let key = "qc_sessions"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadSessions() -> [Session] {
        guard let data = userDefaults.data(forKey: key) else {
            return []
        }

        do {
            return try JSONDecoder().decode([Session].self, from: data)
        } catch {
            return []
        }
    }

    func saveSessions(_ sessions: [Session]) {
        guard let data = try? JSONEncoder().encode(sessions) else {
            return
        }

        userDefaults.set(data, forKey: key)
    }

    func appendSession(_ session: Session) {
        var sessions = loadSessions()
        sessions.append(session)
        saveSessions(sessions)
    }
}
