import SwiftUI
import WebKit
import UIKit

struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool
    @Binding var hadError: Bool
    var reloadTrigger: UUID

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.preferredContentMode = .mobile
        configuration.allowsInlineMediaPlayback = true

        let userContentController = WKUserContentController()
        userContentController.addUserScript(Self.hideWebNavigationScript())
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.scrollView.bounces = true
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.keyboardDismissMode = .interactive
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear

        load(urlString, in: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if context.coordinator.reloadToken != reloadTrigger {
            context.coordinator.reloadToken = reloadTrigger
            load(urlString, in: uiView)
        }
    }

    private func load(_ urlString: String, in webView: WKWebView) {
        guard let url = platformURL(from: urlString) else {
            hadError = true
            isLoading = false
            return
        }

        isLoading = true
        hadError = false

        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        webView.load(request)
    }

    private func platformURL(from urlString: String) -> URL? {
        guard var components = URLComponents(string: urlString) ?? URLComponents(string: "https://questchat.app") else {
            return nil
        }

        var queryItems = components.queryItems ?? []
        if !queryItems.contains(where: { $0.name == "platform" }) {
            queryItems.append(URLQueryItem(name: "platform", value: "iosapp"))
        }
        components.queryItems = queryItems

        return components.url
    }

    private static func hideWebNavigationScript() -> WKUserScript {
        let scriptSource = """
        (function() {
            const selectors = [
                '[data-testid="bottom-nav"]',
                '[data-test="bottom-nav"]',
                '#bottom-nav',
                '.bottom-nav',
                '.bottom-navigation',
                'nav[aria-label="bottom navigation"]',
                'nav[role="tablist"]'
            ];

            const hideNav = () => {
                for (const selector of selectors) {
                    const element = document.querySelector(selector);
                    if (element) {
                        element.style.setProperty('display', 'none', 'important');
                        return true;
                    }
                }

                const candidates = Array.from(document.querySelectorAll('nav, footer, div'));
                const match = candidates.find((el) => {
                    const text = (el.textContent || '').toLowerCase();
                    return ['chat', 'activities', 'stats', 'quests', 'info'].every((keyword) => text.includes(keyword));
                });

                if (match) {
                    match.style.setProperty('display', 'none', 'important');
                    return true;
                }

                return false;
            };

            if (!hideNav()) {
                const observer = new MutationObserver(() => {
                    if (hideNav()) {
                        observer.disconnect();
                    }
                });

                observer.observe(document.documentElement, { childList: true, subtree: true });

                setTimeout(() => observer.disconnect(), 5000);
            }
        })();
        """

        return WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var reloadToken: UUID

        init(_ parent: WebView) {
            self.parent = parent
            self.reloadToken = parent.reloadTrigger
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               ["tel", "mailto"].contains(url.scheme?.lowercased() ?? "") {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handleError()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handleError()
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.reload()
        }

        private func handleError() {
            parent.isLoading = false
            parent.hadError = true
        }
    }
}
