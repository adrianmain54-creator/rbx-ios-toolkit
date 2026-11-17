import SwiftUI
import UIKit

private enum AoidTheme {
    static let background = Color(red: 0.035, green: 0.045, blue: 0.07)
    static let panel = Color(red: 0.085, green: 0.10, blue: 0.14)
    static let accent = Color(red: 0.20, green: 0.88, blue: 0.96)
    static let muted = Color.white.opacity(0.55)
}

struct ContentView: View {
    @EnvironmentObject private var store: ProfileStore
    @State private var showingExport = false
    @State private var exportURL: URL?
    @State private var exportError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AoidTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        profilePicker
                        if let profile = store.selectedProfile {
                            editor(for: profile)
                        } else {
                            ContentUnavailableView("No profile selected", systemImage: "slider.horizontal.3")
                        }
                        compatibilityNote
                    }
                    .padding(18)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingExport) {
                if let url = exportURL {
                    ShareSheet(url: url)
                        .presentationDetents([.medium, .large])
                }
            }
            .alert("Export failed", isPresented: Binding(
                get: { exportError != nil },
                set: { if !$0 { exportError = nil } }
            )) {
                Button("OK", role: .cancel) { exportError = nil }
            } message: {
                Text(exportError ?? "Unknown error")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("AOID")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(4)
                    .foregroundStyle(AoidTheme.accent)
                Spacer()
                Text("iOS • PROFILE MANAGER")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(AoidTheme.muted)
            }
            Text("Adrian fflag")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("VISUAL PROFILES FOR ROBLOX · RIVALS FOCUS")
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(AoidTheme.muted)
        }
        .padding(.top, 8)
    }

    private var profilePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("PROFILES")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(store.profiles) { profile in
                        Button {
                            store.select(profile)
                        } label: {
                            Text(profile.name)
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 11)
                                .foregroundStyle(store.selectedProfileID == profile.id ? .black : .white)
                                .background(store.selectedProfileID == profile.id ? AoidTheme.accent : AoidTheme.panel)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    Button {
                        store.addProfile()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 38, height: 38)
                            .background(AoidTheme.panel)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func editor(for source: VisualProfile) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                sectionTitle("VISUAL SETTINGS")
                Spacer()
                Menu {
                    Button("Duplicate profile", systemImage: "plus.square.on.square") {
                        store.duplicate(source)
                    }
                    Button("Reset built-in presets", systemImage: "arrow.counterclockwise", role: .destructive) {
                        store.resetPresets()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(AoidTheme.accent)
                        .padding(8)
                        .background(AoidTheme.panel)
                        .clipShape(Circle())
                }
            }

            TextField("Profile name", text: binding(source, \.name))
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 9) {
                settingLabel("Texture quality", value: "\(source.textureQuality)")
                Picker("Texture quality", selection: binding(source, \.textureQuality)) {
                    ForEach(0...3, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 9) {
                settingLabel("Anti-aliasing preference", value: "\(source.antiAliasing)x")
                Picker("Anti-aliasing", selection: binding(source, \.antiAliasing)) {
                    ForEach([0, 2, 4, 8], id: \.self) { Text("\($0)x").tag($0) }
                }
                .pickerStyle(.segmented)
            }

            slider("Saturation", value: binding(source, \.saturation), range: 0.5...1.5)
            slider("Contrast", value: binding(source, \.contrast), range: 0.5...1.5)
            slider("Brightness", value: binding(source, \.brightness), range: 0.5...1.5)

            VStack(alignment: .leading, spacing: 9) {
                settingLabel("Skybox preset", value: source.skyboxPreset)
                Picker("Skybox preset", selection: binding(source, \.skyboxPreset)) {
                    ForEach(["Default", "Blue Hour", "Sunset", "Night", "Studio"], id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .tint(AoidTheme.accent)
            }

            VStack(alignment: .leading, spacing: 8) {
                settingLabel("Notes", value: "")
                TextField("Add a note for this profile", text: binding(source, \.notes), axis: .vertical)
                    .lineLimit(2...4)
                    .textFieldStyle(.roundedBorder)
            }

            Button {
                export(profile: source)
            } label: {
                Label("EXPORT PROFILE JSON", systemImage: "square.and.arrow.up")
                    .font(.system(size: 12, weight: .black))
                    .tracking(1)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(AoidTheme.accent)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding(17)
        .background(AoidTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var compatibilityNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(AoidTheme.accent)
            Text("Profiles are saved in this app and exported as JSON. Roblox does not automatically read these files. Skybox, texture and shader changes require support inside Roblox or the game.")
                .font(.system(size: 11))
                .foregroundStyle(AoidTheme.muted)
        }
        .padding(14)
        .background(AoidTheme.panel.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func binding<T>(_ profile: VisualProfile, _ keyPath: WritableKeyPath<VisualProfile, T>) -> Binding<T> {
        Binding(
            get: { store.profiles.first(where: { $0.id == profile.id })?[keyPath: keyPath] ?? profile[keyPath: keyPath] },
            set: { newValue in
                guard var updated = store.profiles.first(where: { $0.id == profile.id }) else { return }
                updated[keyPath: keyPath] = newValue
                store.update(updated)
            }
        )
    }

    private func slider(_ title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            settingLabel(title, value: String(format: "%.2f", value.wrappedValue))
            Slider(value: value, in: range, step: 0.05)
                .tint(AoidTheme.accent)
        }
    }

    private func settingLabel(_ title: String, value: String) -> some View {
        HStack {
            Text(title).font(.system(size: 13, weight: .medium))
            Spacer()
            Text(value).font(.system(size: 11, weight: .semibold, design: .monospaced)).foregroundStyle(AoidTheme.accent)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .black))
            .tracking(2)
            .foregroundStyle(AoidTheme.accent)
    }

    private func export(profile: VisualProfile) {
        guard let data = store.exportData(for: profile) else {
            exportError = "Could not encode this profile."
            return
        }
        let safeName = profile.name.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(safeName).json")
        do {
            try data.write(to: url, options: .atomic)
            exportURL = url
            showingExport = true
        } catch {
            exportError = error.localizedDescription
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
