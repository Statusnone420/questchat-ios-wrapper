import SwiftUI

struct StatsView: View {
    @StateObject var viewModel: StatsViewModel

    private let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 2
        return formatter
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sessions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar.doc.horizontal.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No sessions yet. Start a Focus timer to see stats here.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else {
                    List(viewModel.sessions) { session in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(durationText(for: session))
                                .font(.headline)
                            Text(dateText(for: session))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Stats")
            .onAppear {
                viewModel.load()
            }
        }
    }

    private func durationText(for session: Session) -> String {
        let duration = TimeInterval(session.durationSeconds)
        return durationFormatter.string(from: duration) ?? "0s"
    }

    private func dateText(for session: Session) -> String {
        let started = dateFormatter.string(from: session.startedAt)
        return started
    }
}

#Preview {
    StatsView(viewModel: StatsViewModel(sessionStore: UserDefaultsSessionStore()))
}
