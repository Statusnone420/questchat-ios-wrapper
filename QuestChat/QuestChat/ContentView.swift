import SwiftUI

struct ContentView: View {
    @State private var isShowingSettings = false

    private let tabs: [(title: String, systemImage: String, url: String)] = [
        ("Chat", "bubble.left.and.bubble.right.fill", "https://questchat.app/?platform=iosapp#chat"),
        ("Activities", "figure.walk", "https://questchat.app/?platform=iosapp#activities"),
        ("Stats", "chart.bar.xaxis", "https://questchat.app/?platform=iosapp#stats"),
        ("Quests", "star.circle.fill", "https://questchat.app/?platform=iosapp#quests"),
        ("Info", "info.circle.fill", "https://questchat.app/?platform=iosapp#info")
    ]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView {
                ForEach(tabs, id: \.title) { tab in
                    WebTabView(urlString: tab.url)
                        .tabItem {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                }
            }
            .tint(.primary)
            .background(Color(.systemBackground).ignoresSafeArea())

            Button {
                isShowingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .imageScale(.large)
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 16)
            .padding(.top, 14)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
