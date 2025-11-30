import SwiftUI

private struct SafariDestination: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsView: View {
    @AppStorage("settings_haptics_enabled") private var hapticsEnabled = true
    @AppStorage("settings_confirm_end_timer") private var confirmEndTimer = true

    @State private var selectedLink: SafariDestination?

    var body: some View {
        NavigationStack {
            List {
                header

                Section("Preferences") {
                    Toggle("Haptics", isOn: $hapticsEnabled)
                    Toggle("Confirm before ending timer", isOn: $confirmEndTimer)
                }

                Section("Links") {
                    Button {
                        selectedLink = SafariDestination(url: URL(string: "https://questchat.app")!)
                    } label: {
                        Label("Visit questchat.app", systemImage: "safari")
                    }

                    Button {
                        selectedLink = SafariDestination(url: URL(string: "https://questchat.app/?platform=iosapp#info")!)
                    } label: {
                        Label("View project info / Ko-fi", systemImage: "heart")
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

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "message.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundStyle(.blue)
                .padding(8)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("QuestChat")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Timer • Quests • Chat")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SettingsView()
}
