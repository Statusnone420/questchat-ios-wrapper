import SwiftUI
import WebKit

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

struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool
    @Binding var hadError: Bool
    var reloadTrigger: UUID

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        loadURL(in: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if context.coordinator.currentURLString != urlString || context.coordinator.reloadToken != reloadTrigger {
            context.coordinator.currentURLString = urlString
            context.coordinator.reloadToken = reloadTrigger
            loadURL(in: uiView)
        }
    }

    func loadURL(in webView: WKWebView) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var currentURLString: String
        var reloadToken: UUID

        init(_ parent: WebView) {
            self.parent = parent
            self.currentURLString = parent.urlString
            self.reloadToken = parent.reloadTrigger
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.hadError = false
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.hadError = true
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.hadError = true
        }
    }
}

#Preview {
    ContentView()
}
