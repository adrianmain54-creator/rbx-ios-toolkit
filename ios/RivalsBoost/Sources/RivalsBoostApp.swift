import SwiftUI
import UIKit

@main
struct RivalsBoostApp: App {
    var body: some Scene {
        WindowGroup { RootView().preferredColorScheme(.dark) }
    }
}

enum BoostStyle {
    static let background = Color(red: 0.035, green: 0.045, blue: 0.065)
    static let panel = Color(red: 0.075, green: 0.09, blue: 0.12)
    static let accent = Color(red: 0.38, green: 0.95, blue: 0.72)
    static let muted = Color(red: 0.58, green: 0.64, blue: 0.70)
}

enum PlayPreset: String, CaseIterable, Identifiable {
    case lowLatency = "Low Latency"
    case balanced = "Balanced"
    case visual = "Visual"
    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .lowLatency: return "Prioritizes responsiveness and cooler operation"
        case .balanced: return "A middle ground for everyday play"
        case .visual: return "Keeps the picture quality you can control in-game"
        }
    }
    var symbol: String {
        switch self {
        case .lowLatency: return "bolt.fill"
        case .balanced: return "slider.horizontal.3"
        case .visual: return "sparkles"
        }
    }
    var steps: [String] {
        switch self {
        case .lowLatency:
            return ["Set Roblox Graphics Mode to Manual, then lower the quality slider.", "Close other demanding apps before launching Roblox.", "Turn off Low Power Mode while playing, if battery level allows.", "Keep the iPad cool and avoid covering it while playing."]
        case .balanced:
            return ["Start with Roblox Graphics Mode on Automatic.", "If frames stutter, switch to Manual and lower quality one step at a time.", "Close unused apps and keep enough free storage.", "Use a stable Wi-Fi connection."]
        case .visual:
            return ["Raise Roblox graphics quality gradually until performance becomes unstable.", "Use only visual options offered by the experience itself.", "Keep the iPad ventilated; heat can reduce sustained performance.", "Return to a lower quality level if the device gets hot."]
        }
    }
}

struct RootView: View {
    @State private var selectedPreset: PlayPreset = .lowLatency
    @State private var selectedGeneration = "Not sure yet"
    var body: some View {
        TabView {
            HomeView(selectedPreset: $selectedPreset).tabItem { Label("Home", systemImage: "square.grid.2x2.fill") }
            PresetsView(selectedPreset: $selectedPreset).tabItem { Label("Presets", systemImage: "slider.horizontal.3") }
            VisualLabView().tabItem { Label("Visual Lab", systemImage: "mountain.2.fill") }
            DeviceView(selectedGeneration: $selectedGeneration).tabItem { Label("My iPad", systemImage: "ipad") }
        }
        .tint(BoostStyle.accent)
    }
}

struct ScreenShell<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title).font(.system(size: 32, weight: .bold, design: .rounded))
                        Text(subtitle).font(.subheadline).foregroundStyle(BoostStyle.muted)
                    }
                    content
                }
                .frame(maxWidth: 760, alignment: .leading)
                .padding(.horizontal, 22).padding(.top, 22).padding(.bottom, 36)
                .frame(maxWidth: .infinity)
            }
            .background(BoostStyle.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct Panel<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 13) { content }
            .padding(18).frame(maxWidth: .infinity, alignment: .leading)
            .background(BoostStyle.panel, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.06), lineWidth: 1))
    }
}

struct HomeView: View {
    @Binding var selectedPreset: PlayPreset
    var body: some View {
        ScreenShell(title: "Rivals Boost", subtitle: "Your iPad Air companion for smoother sessions.") {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24).fill(LinearGradient(colors: [Color(red: 0.10, green: 0.32, blue: 0.29), Color(red: 0.10, green: 0.13, blue: 0.24), Color(red: 0.20, green: 0.12, blue: 0.30)], startPoint: .topLeading, endPoint: .bottomTrailing))
                Circle().fill(BoostStyle.accent.opacity(0.16)).frame(width: 190).offset(x: 205, y: -58)
                VStack(alignment: .leading, spacing: 10) {
                    Text("PLAY SMARTER").font(.caption.weight(.bold)).tracking(2).foregroundStyle(BoostStyle.accent)
                    Text("Less lag.\nMore control.").font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("Guides and presets for the settings Roblox actually exposes.").font(.subheadline).foregroundStyle(.white.opacity(0.76)).frame(maxWidth: 340, alignment: .leading)
                }.padding(22)
            }.frame(height: 210)
            Panel {
                HStack {
                    Label("ACTIVE GUIDE", systemImage: "bolt.fill").font(.caption.weight(.bold)).foregroundStyle(BoostStyle.accent)
                    Spacer()
                    Text("iPad Air").font(.caption.weight(.semibold)).foregroundStyle(BoostStyle.muted)
                }
                Text(selectedPreset.rawValue).font(.title2.bold())
                Text(selectedPreset.subtitle).foregroundStyle(BoostStyle.muted)
            }
            Panel {
                Label("Quick reality check", systemImage: "info.circle.fill").font(.headline)
                Text("Rivals Boost does not inject into Roblox or change its private files. It gives you safe, practical settings to apply yourself.").font(.subheadline).foregroundStyle(BoostStyle.muted)
            }
            Panel {
                Label("Before your next match", systemImage: "checkmark.seal.fill").font(.headline)
                QuickCheckRow(text: "Low Power Mode off, if battery permits")
                QuickCheckRow(text: "Graphics quality adjusted in Roblox")
                QuickCheckRow(text: "iPad cool with vents unobstructed")
                QuickCheckRow(text: "Stable Wi-Fi connection")
            }
        }
    }
}

struct QuickCheckRow: View {
    let text: String
    @State private var checked = false
    var body: some View {
        Button { checked.toggle() } label: {
            HStack(spacing: 10) {
                Image(systemName: checked ? "checkmark.circle.fill" : "circle").foregroundStyle(checked ? BoostStyle.accent : BoostStyle.muted)
                Text(text).foregroundStyle(.white)
                Spacer()
            }.contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
}

struct PresetsView: View {
    @Binding var selectedPreset: PlayPreset
    var body: some View {
        ScreenShell(title: "Play presets", subtitle: "Choose a guide. Nothing is silently changed on your device.") {
            ForEach(PlayPreset.allCases) { preset in
                Button { selectedPreset = preset } label: {
                    Panel {
                        HStack {
                            Image(systemName: preset.symbol).font(.title2).foregroundStyle(BoostStyle.accent).frame(width: 38)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(preset.rawValue).font(.headline).foregroundStyle(.white)
                                Text(preset.subtitle).font(.subheadline).foregroundStyle(BoostStyle.muted)
                            }
                            Spacer()
                            Image(systemName: selectedPreset == preset ? "checkmark.circle.fill" : "circle").foregroundStyle(selectedPreset == preset ? BoostStyle.accent : BoostStyle.muted)
                        }
                    }
                }.buttonStyle(.plain)
            }
            Panel {
                Text("Your setup steps").font(.headline)
                ForEach(Array(selectedPreset.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text(String(format: "%02d", index + 1)).font(.caption.monospacedDigit().bold()).foregroundStyle(BoostStyle.accent)
                        Text(step).font(.subheadline).foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
            Text("FPS note: the app cannot unlock a frame-rate cap. Actual FPS depends on your iPad model, display, Roblox and the experience.").font(.footnote).foregroundStyle(BoostStyle.muted)
        }
    }
}

struct VisualLabView: View {
    @State private var sky = 0
    private let skies: [(String, [Color])] = [
        ("Aurora", [Color(red: 0.06, green: 0.25, blue: 0.32), Color(red: 0.30, green: 0.20, blue: 0.48), Color(red: 0.05, green: 0.08, blue: 0.16)]),
        ("Sunset", [Color(red: 0.95, green: 0.40, blue: 0.25), Color(red: 0.48, green: 0.20, blue: 0.43), Color(red: 0.10, green: 0.10, blue: 0.25)]),
        ("Midnight", [Color(red: 0.02, green: 0.06, blue: 0.16), Color(red: 0.08, green: 0.14, blue: 0.28), Color(red: 0.02, green: 0.03, blue: 0.08)])
    ]
    var body: some View {
        ScreenShell(title: "Visual Lab", subtitle: "Preview original looks and supported content.") {
            Panel {
                Text("Skybox concept").font(.headline)
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: skies[sky].1, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(skies[sky].0.uppercased()).font(.caption.weight(.bold)).tracking(2)
                            Text("Original preview concept").font(.caption).foregroundStyle(.white.opacity(0.7))
                        }.padding(16)
                    }.frame(height: 190)
                Picker("Sky concept", selection: $sky) {
                    ForEach(skies.indices, id: \.self) { index in Text(skies[index].0).tag(index) }
                }.pickerStyle(.segmented)
                Text("In-app preview only. It cannot replace the skybox in someone else's Roblox experience. Experience creators can publish their own skyboxes in Roblox Studio.").font(.footnote).foregroundStyle(BoostStyle.muted)
            }
            Panel {
                Label("Rivals texture pack", systemImage: "square.3.layers.3d").font(.headline)
                Text("Texture concepts and manifests can be organized here. Applying custom textures to the live Rivals client is not supported by this app.").font(.subheadline).foregroundStyle(BoostStyle.muted)
                HStack {
                    Image(systemName: "photo.on.rectangle.angled").foregroundStyle(BoostStyle.accent)
                    Text("Asset gallery — starter section").font(.subheadline.weight(.medium))
                    Spacer()
                    Text("Preview").font(.caption).foregroundStyle(BoostStyle.muted)
                }.padding(12).background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

struct DeviceView: View {
    @Binding var selectedGeneration: String
    private let generations = ["Not sure yet", "iPad Air (M1, 2022)", "iPad Air (M2, 2024)", "iPad Air (M3, 2025)", "Other / older iPad Air"]
    var body: some View {
        ScreenShell(title: "Your iPad", subtitle: "A device-aware setup, without guessing your chip.") {
            Panel {
                Label("Device family", systemImage: "ipad.gen2").font(.headline)
                Text("iPad Air").font(.title2.bold())
                Text("You selected iPad Air. Choose the generation if you know it; otherwise leave it on Not sure yet.").font(.subheadline).foregroundStyle(BoostStyle.muted)
                Picker("Generation", selection: $selectedGeneration) {
                    ForEach(generations, id: \.self) { Text($0).tag($0) }
                }.pickerStyle(.menu)
            }
            Panel {
                Label("Find your exact model", systemImage: "magnifyingglass").font(.headline)
                Text("On your iPad, open Settings → General → About. Look for Model Name and Model Number.").font(.subheadline).foregroundStyle(BoostStyle.muted)
                Button {
                    UIPasteboard.general.string = "Settings → General → About → Model Name / Model Number"
                } label: {
                    Label("Copy where to look", systemImage: "doc.on.doc").font(.subheadline.weight(.semibold))
                }.tint(BoostStyle.accent)
            }
            Panel {
                Label("What we can and can't promise", systemImage: "gauge.with.dots.needle.67").font(.headline)
                DeviceFact(title: "Can help", detail: "Roblox graphics setup, thermal habits, background-app hygiene and connection checks.")
                DeviceFact(title: "Cannot force", detail: "A 60+ FPS unlock, custom shaders, private client flags or Rivals textures in a third-party game.")
                DeviceFact(title: "No account-risk tricks", detail: "No injection, exploit executor, anti-cheat bypass or hidden client patching.")
            }
        }
    }
}

struct DeviceFact: View {
    let title: String
    let detail: String
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(BoostStyle.accent)
            Text(detail).font(.subheadline).foregroundStyle(BoostStyle.muted)
        }
    }
}
