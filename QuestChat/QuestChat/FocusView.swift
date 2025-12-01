import SwiftUI

struct FocusView: View {
    @StateObject private var viewModel: FocusViewModel

    init(viewModel: FocusViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("Focus Timer")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(formattedTime)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(viewModel.hasFinishedOnce ? .green : .primary)
            }
            .padding(.top, 24)

            HStack(spacing: 16) {
                Button(action: viewModel.startOrPause) {
                    Label(viewModel.isRunning ? "Pause" : "Start", systemImage: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(action: viewModel.reset) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private var formattedTime: String {
        let minutes = viewModel.secondsRemaining / 60
        let seconds = viewModel.secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    FocusView(viewModel: FocusViewModel())
}
