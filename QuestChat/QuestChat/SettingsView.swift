import SwiftUI

struct LinkDestination: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsView: View {
    @AppStorage("settings_haptics_enabled") private var hapticsEnabled = true
    @AppStorage("settings_confirm_end_timer") private var confirmEndTimer = true

    @State private var selectedLink: LinkDestination?

    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading, spacing: 4) {
                    Text("QuestChat")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Timer • Quests • Chat")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                Section {
                    Toggle("Haptics", isOn: $hapticsEnabled)
                    Toggle("Confirm before ending timer", isOn: $confirmEndTimer)
                }

                Section {
                    Button {
                        selectedLink = LinkDestination(url: URL(string: "https://questchat.app")!)
                    } label: {
                        Label("Open questchat.app", systemImage: "safari")
                    }

                    Button {
                        selectedLink = LinkDestination(url: URL(string: "https://questchat.app/#info")!)
                    } label: {
                        Label("Project info / Ko-fi", systemImage: "heart")
                    }
                }

                Section {
                    Text("Built with love as a focus helper, not medical advice.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("QuestChat")
            .sheet(item: $selectedLink) { destination in
                SafariView(url: destination.url)
            }
        }
    }
}

#Preview {
    SettingsView()
}
