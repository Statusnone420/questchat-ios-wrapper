import Foundation

struct Session: Identifiable, Codable, Equatable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date
    let durationSeconds: Int

    init(id: UUID = UUID(), startedAt: Date, endedAt: Date, durationSeconds: Int) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = durationSeconds
    }

    init(start: Date, end: Date) {
        let duration = Int(end.timeIntervalSince(start))
        self.init(startedAt: start, endedAt: end, durationSeconds: max(duration, 0))
    }
}
