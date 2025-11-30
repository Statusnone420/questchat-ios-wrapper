import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WebTabView(urlString: "https://questchat.app/?platform=iosapp#chat")
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }

            WebTabView(urlString: "https://questchat.app/?platform=iosapp#activities")
                .tabItem {
                    Label("Activities", systemImage: "figure.walk")
                }

            WebTabView(urlString: "https://questchat.app/?platform=iosapp#stats")
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }

            WebTabView(urlString: "https://questchat.app/?platform=iosapp#quests")
                .tabItem {
                    Label("Quests", systemImage: "star.circle.fill")
                }

            WebTabView(urlString: "https://questchat.app/?platform=iosapp#info")
                .tabItem {
                    Label("Info", systemImage: "info.circle.fill")
                }
        }
    }
}

struct WebTabView: View {
    let urlString: String

    @State private var isLoading = true
    @State private var hadError = false
    @State private var reloadTrigger = UUID()

    var body: some View {
        ZStack {
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
                .ignoresSafeArea()
            }

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
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    ContentView()
}
