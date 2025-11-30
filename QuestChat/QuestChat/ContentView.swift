import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ChatTabView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }

            ActivitiesTabView()
                .tabItem {
                    Label("Activities", systemImage: "figure.walk")
                }

            StatsTabView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }

            QuestsTabView()
                .tabItem {
                    Label("Quests", systemImage: "star.circle.fill")
                }

            InfoTabView()
                .tabItem {
                    Label("Info", systemImage: "info.circle.fill")
                }
        }
    }
}

private struct WebTabView: View {
    let urlString: String

    @State private var isLoading = true
    @State private var hadError = false
    @State private var reloadTrigger = UUID()

    var body: some View {
        ZStack {
            if hadError {
                VStack(spacing: 16) {
                    Text("QuestChat needs a connection. Please check your internet and try again.")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        hadError = false
                        isLoading = true
                        reloadTrigger = UUID()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                }
            }
        }
    }
}

private struct ChatTabView: View {
    var body: some View {
        WebTabView(urlString: "https://questchat.app/?platform=iosapp#chat")
    }
}

private struct ActivitiesTabView: View {
    var body: some View {
        WebTabView(urlString: "https://questchat.app/?platform=iosapp#activities")
    }
}

private struct StatsTabView: View {
    var body: some View {
        WebTabView(urlString: "https://questchat.app/?platform=iosapp#stats")
    }
}

private struct QuestsTabView: View {
    var body: some View {
        WebTabView(urlString: "https://questchat.app/?platform=iosapp#quests")
    }
}

private struct InfoTabView: View {
    var body: some View {
        WebTabView(urlString: "https://questchat.app/?platform=iosapp#info")
    }
}

#Preview {
    ContentView()
}
