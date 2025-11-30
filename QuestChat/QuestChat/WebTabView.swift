import SwiftUI

struct WebTabView: View {
    let urlString: String

    @State private var isLoading = true
    @State private var hadError = false
    @State private var reloadTrigger = UUID()

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            WebView(
                urlString: urlString,
                isLoading: $isLoading,
                hadError: $hadError,
                reloadTrigger: reloadTrigger
            )
            .ignoresSafeArea()

            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading QuestChat…")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .ignoresSafeArea()
            }

            if hadError {
                VStack(spacing: 16) {
                    Text("QuestChat needs a connection. Please check your internet and try again.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        hadError = false
                        isLoading = true
                        reloadTrigger = UUID()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    WebTabView(urlString: "https://questchat.app")
}
