import SwiftUI

enum ShaderLook: String, CaseIterable, Identifiable {
    case neon = "Neon"
    case cinematic = "Cinematic"
    case crisp = "Crisp"
    var id: String { rawValue }
    var mode: Float {
        switch self {
        case .neon: return 0
        case .cinematic: return 1
        case .crisp: return 2
        }
    }
    var description: String {
        switch self {
        case .neon: return "Boosted colour with cool neon highlights."
        case .cinematic: return "Deeper contrast with warm highlights and cool shadows."
        case .crisp: return "A restrained contrast and saturation lift."
        }
    }
}

private struct ShaderPresetExport: Codable {
    let schemaVersion: Int
    let name: String
    let intensity: Double
    let enabled: Bool
    let description: String
}

struct ShaderStudioCard: View {
    @State private var look: ShaderLook = .neon
    @State private var intensity = 0.72
    @State private var effectEnabled = true

    private var exportText: String {
        let preset = ShaderPresetExport(
            schemaVersion: 1,
            name: look.rawValue,
            intensity: intensity,
            enabled: effectEnabled,
            description: look.description
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(preset),
              let text = String(data: data, encoding: .utf8) else {
            return "{\"error\":\"Could not encode shader preset\"}"
        }
        return text
    }

    var body: some View {
        Panel {
            HStack {
                Label("Shader Studio", systemImage: "wand.and.stars").font(.headline)
                Spacer()
                Text("LIVE PREVIEW").font(.caption2.weight(.bold)).tracking(1.2).foregroundStyle(BoostStyle.accent)
            }
            ShaderPreviewScene(look: look, intensity: intensity, enabled: effectEnabled)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(alignment: .bottomLeading) {
                    Text(look.rawValue.uppercased())
                        .font(.caption.weight(.bold)).tracking(2)
                        .padding(10)
                        .background(.black.opacity(0.38), in: Capsule())
                        .padding(12)
                }
            Picker("Shader look", selection: $look) {
                ForEach(ShaderLook.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }.pickerStyle(.segmented)
            Text(look.description).font(.caption).foregroundStyle(BoostStyle.muted)
            Toggle("Enable preview effect", isOn: $effectEnabled).tint(BoostStyle.accent)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Intensity").font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(Int(intensity * 100))%").font(.caption.monospacedDigit()).foregroundStyle(BoostStyle.accent)
                }
                Slider(value: $intensity, in: 0...1).tint(BoostStyle.accent)
            }
            ShareLink(item: exportText, subject: Text("Rivals Boost shader preset"), preview: SharePreview("\(look.rawValue) shader preset")) {
                Label("Export shader preset", systemImage: "square.and.arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(BoostStyle.accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
            }
            .tint(BoostStyle.accent)
            Text("Export creates a shareable JSON preset for Rivals Boost or your own creative tools. The Metal effect runs in this app's preview only; it is not loaded by Roblox Rivals.")
                .font(.footnote).foregroundStyle(BoostStyle.muted)
        }
    }
}

private struct ShaderPreviewScene: View {
    let look: ShaderLook
    let intensity: Double
    let enabled: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.16, blue: 0.38),
                    Color(red: 0.34, green: 0.16, blue: 0.48),
                    Color(red: 0.96, green: 0.39, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(RadialGradient(colors: [.white.opacity(0.95), .cyan.opacity(0.55), .clear], center: .center, startRadius: 4, endRadius: 90))
                .frame(width: 180, height: 180)
                .offset(x: 105, y: -45)
                .blur(radius: 2)
            Ellipse()
                .fill(Color(red: 0.035, green: 0.055, blue: 0.12).opacity(0.92))
                .frame(width: 520, height: 115)
                .rotationEffect(.degrees(-8))
                .offset(x: -12, y: 125)
            HStack(alignment: .bottom, spacing: 9) {
                ForEach(0..<8) { index in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.10 + Double(index % 3) * 0.08))
                        .frame(width: 22, height: CGFloat(42 + (index * 19) % 85))
                }
            }
            .offset(y: 82)
            VStack(alignment: .leading, spacing: 5) {
                Text("RIVALS BOOST").font(.caption2.weight(.heavy)).tracking(2.5)
                Text("VISUAL LAB").font(.system(size: 25, weight: .black, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(16)
        }
        .compositingGroup()
        .modifier(ShaderLookModifier(look: look, intensity: intensity, enabled: enabled))
    }
}

private struct ShaderLookModifier: ViewModifier {
    let look: ShaderLook
    let intensity: Double
    let enabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if enabled {
            content.colorEffect(
                ShaderLibrary.default.rivalsBoostGrade(
                    .float(Float(intensity)),
                    .float(look.mode)
                )
            )
        } else {
            content
        }
    }
}
