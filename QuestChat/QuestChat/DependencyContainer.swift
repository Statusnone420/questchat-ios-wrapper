import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()

    private let sessionStore: SessionStore

    init(sessionStore: SessionStore = UserDefaultsSessionStore()) {
        self.sessionStore = sessionStore
    }

    func makeFocusViewModel() -> FocusViewModel {
        FocusViewModel(sessionStore: sessionStore)
    }

    func makeStatsViewModel() -> StatsViewModel {
        StatsViewModel(sessionStore: sessionStore)
    }
}
