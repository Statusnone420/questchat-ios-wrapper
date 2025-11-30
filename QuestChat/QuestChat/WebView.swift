import SwiftUI
import WebKit

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
        let hideBottomNavScript = """
        (function() {
            const params = new URLSearchParams(window.location.search);
            const isIosApp = params.get('platform') === 'iosapp';
            if (!isIosApp) {
                return;
            }

            const labels = ['Chat', 'Activities', 'Stats', 'Quests', 'Info'];

            const hideNav = () => {
                const candidates = Array.from(document.querySelectorAll('nav, footer, div, section'));
                const target = candidates.find(el => {
                    const text = (el.textContent || '').trim();
                    return labels.every(label => text.includes(label));
                });

                if (target) {
                    target.style.setProperty('display', 'none', 'important');
                    return true;
                }

                return false;
            };

            const applyInitialTabFromHash = () => {
                const hashValue = (window.location.hash || '').replace(/^#/, '').toLowerCase();
                const mapping = {
                    chat: 'chat',
                    activities: 'activities',
                    stats: 'stats',
                    quests: 'quests',
                    info: 'info'
                };

                const targetTab = mapping[hashValue];
                if (!targetTab) {
                    return true;
                }

                const elements = Array.from(document.querySelectorAll('a, button, div, span'));
                const targetEl = elements.find(el => (el.textContent || '').trim().toLowerCase() === targetTab);
                if (targetEl && typeof targetEl.click === 'function') {
                    targetEl.click();
                    return true;
                }

                return false;
            };

            const hidden = hideNav();
            const tabSelected = applyInitialTabFromHash();

            if (( !hidden || !tabSelected ) && typeof MutationObserver !== 'undefined' && document.body) {
                const observer = new MutationObserver((_, obs) => {
                    const navHidden = hidden || hideNav();
                    const tabApplied = tabSelected || applyInitialTabFromHash();

                    if (navHidden && tabApplied) {
                        obs.disconnect();
                    }
                });
                observer.observe(document.body, { childList: true, subtree: true });
            }
        })();
        """
        let userScript = WKUserScript(source: hideBottomNavScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(userScript)
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black

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
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var reloadToken: UUID

        init(_ parent: WebView) {
            self.parent = parent
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
