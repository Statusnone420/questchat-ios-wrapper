import SwiftUI

struct ContentView: View {
    @StateObject private var focusViewModel: FocusViewModel

    private let statsView: StatsView
    private let tabs: [(title: String, systemImage: String, url: String)] = [
        ("Chat", "bubble.left.and.bubble.right.fill", "https://questchat.app/?platform=iosapp#chat"),
        ("Activities", "figure.walk", "https://questchat.app/?platform=iosapp#activities"),
        ("Quests", "star.circle.fill", "https://questchat.app/?platform=iosapp#quests"),
        ("Info", "info.circle.fill", "https://questchat.app/?platform=iosapp#info")
    ]

    @State private var isShowingSettings = false
    @State private var selectedTab = "Chat"
    @State private var reloadTokens: [String: UUID]

    @AppStorage("settings_haptics_enabled") private var hapticsEnabled = true

    private let impactGenerator = UIImpactFeedbackGenerator(style: .soft)

    init(focusViewModel: FocusViewModel, statsView: StatsView) {
        _focusViewModel = StateObject(wrappedValue: focusViewModel)
        self.statsView = statsView
        _reloadTokens = State(initialValue: Dictionary(uniqueKeysWithValues: tabs.map { ($0.title, UUID()) }))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                TabView(selection: $selectedTab) {
                    FocusView(viewModel: focusViewModel)
                        .tabItem {
                            Label("Focus", systemImage: "timer")
                        }
                        .tag("Focus")

                    statsView
                        .tabItem {
                            Label("Stats", systemImage: "chart.bar.xaxis")
                        }
                        .tag("Stats")

                    ForEach(tabs, id: \.title) { tab in
                        WebTabView(
                            urlString: tab.url,
                            reloadTrigger: binding(for: tab.title)
                        )
                        .tabItem {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .tag(tab.title)
                    }
                }
                .tint(.primary)
                .background(Color(.systemBackground).ignoresSafeArea())
            }
            .background(Color(.systemBackground))
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar { toolbarContent }
            .navigationTitle(selectedTab)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .onChange(of: selectedTab) { _ in
                triggerHaptic()
            }
            .onAppear {
                impactGenerator.prepare()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "message.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("QuestChat")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Timer • Quests • Chat")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }

                Spacer()
            }
            .padding(.horizontal)

            Divider()
        }
        .padding(.top, 4)
        .background(.ultraThinMaterial)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Text(selectedTab)
                .font(.headline)
        }

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                reloadTokens[selectedTab] = UUID()
                triggerHaptic()
            } label: {
                Image(systemName: "arrow.clockwise")
            }

            Button {
                isShowingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
            }
        }
    }

    private func binding(for title: String) -> Binding<UUID> {
        Binding(
            get: { reloadTokens[title, default: UUID()] },
            set: { reloadTokens[title] = $0 }
        )
    }

    private func triggerHaptic() {
        guard hapticsEnabled else { return }
        impactGenerator.impactOccurred(intensity: 0.6)
    }
}

#Preview {
    ContentView(
        focusViewModel: FocusViewModel(),
        statsView: StatsView(viewModel: StatsViewModel(sessionStore: UserDefaultsSessionStore()))
    )
}
