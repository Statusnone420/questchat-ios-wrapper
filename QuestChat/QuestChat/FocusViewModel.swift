import Combine
import Foundation

@MainActor
final class FocusViewModel: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var secondsRemaining: Int
    @Published var hasFinishedOnce: Bool = false

    private let totalDuration: Int
    private var timerCancellable: AnyCancellable?
    private let sessionStore: SessionStore
    private var currentStartDate: Date?

    init(duration: Int = 25 * 60, sessionStore: SessionStore = UserDefaultsSessionStore()) {
        self.totalDuration = duration
        self.secondsRemaining = duration
        self.sessionStore = sessionStore
    }

    func startOrPause() {
        isRunning ? pause() : start()
    }

    func reset() {
        timerCancellable?.cancel()
        timerCancellable = nil
        secondsRemaining = totalDuration
        isRunning = false
        hasFinishedOnce = false
        currentStartDate = nil
    }

    func tick() {
        guard isRunning else { return }
        guard secondsRemaining > 0 else {
            finish()
            return
        }

        secondsRemaining -= 1

        if secondsRemaining <= 0 {
            finish()
        }
    }

    private func start() {
        guard !isRunning else { return }
        if secondsRemaining <= 0 {
            reset()
        }

        if secondsRemaining == totalDuration {
            currentStartDate = Date()
        }

        isRunning = true

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func pause() {
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func finish() {
        isRunning = false
        hasFinishedOnce = true
        timerCancellable?.cancel()
        timerCancellable = nil
        recordSession()
    }

    private func recordSession() {
        let endDate = Date()
        let startDate = currentStartDate ?? endDate.addingTimeInterval(Double(-totalDuration))
        let session = Session(start: startDate, end: endDate)
        sessionStore.appendSession(session)
    }
}
