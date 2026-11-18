import SwiftUI

private enum TextureStyle: String, CaseIterable, Identifiable, Codable {
    case grid = "Tactical Grid"
    case carbon = "Carbon"
    case digital = "Digital"
    case clean = "Clean"
    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .grid: return "Fine technical lines with bright accent points"
        case .carbon: return "Alternating woven blocks and dark contrast"
        case .digital: return "A clean digital pixel pattern"
        case .clean: return "Minimal surfaces with restrained highlights"
        }
    }
}

private struct TexturePackManifest: Codable {
    let schemaVersion: Int
    let packName: String
    let target: String
    let style: String
    let accent: String
    let tileScale: Double
    let note: String
}

struct TexturePackStudioCard: View {
    @State private var style: TextureStyle = .grid
    @State private var accent = 0
    @State private var tileScale = 0.55
    @State private var packName = "Rivals Custom Set"
    private let accents: [(String, Color, String)] = [
        ("Mint", Color(red: 0.35, green: 0.96, blue: 0.72), "#59F5B8"),
        ("Violet", Color(red: 0.68, green: 0.48, blue: 1.0), "#AD7BFF"),
        ("Ice", Color(red: 0.38, green: 0.78, blue: 1.0), "#61C7FF"),
        ("Amber", Color(red: 1.0, green: 0.68, blue: 0.28), "#FFAD47")
    ]
    private var manifest: String {
        let value = TexturePackManifest(
            schemaVersion: 1,
            packName: packName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Pack" : packName,
            target: "Rivals-inspired original concept assets",
            style: style.rawValue,
            accent: accents[accent].2,
            tileScale: tileScale,
            note: "Design manifest and preview only. Not an import file for the Roblox iPad client."
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(value),
              let result = String(data: data, encoding: .utf8) else {
            return "{\"error\":\"Manifest export failed\"}"
        }
        return result
    }
    var body: some View {
        Panel {
            HStack {
                Label("Texture Pack Studio", systemImage: "square.3.layers.3d").font(.headline)
                Spacer()
                Text("DESIGN PREVIEW").font(.caption2.bold()).tracking(1).foregroundStyle(BoostStyle.accent)
            }
            TextField("Pack name", text: $packName).textFieldStyle(.roundedBorder)
            TexturePatternPreview(style: style, accent: accents[accent].1, scale: tileScale)
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            Picker("Pattern", selection: $style) {
                ForEach(TextureStyle.allCases) { item in Text(item.rawValue).tag(item) }
            }.pickerStyle(.menu)
            Text(style.subtitle).font(.caption).foregroundStyle(BoostStyle.muted)
            HStack(spacing: 12) {
                ForEach(accents.indices, id: \.self) { index in
                    Button { accent = index } label: {
                        Circle().fill(accents[index].1).frame(width: 30, height: 30)
                            .overlay(Circle().stroke(.white, lineWidth: accent == index ? 2 : 0))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(accents[index].0) accent")
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Tile scale").font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(Int(tileScale * 100))%").font(.caption.monospacedDigit()).foregroundStyle(BoostStyle.accent)
                }
                Slider(value: $tileScale, in: 0.25...1).tint(BoostStyle.accent)
            }
            ShareLink(item: manifest, subject: Text("Rivals Boost texture pack manifest"), preview: SharePreview("Texture pack manifest")) {
                Label("Export pack manifest", systemImage: "square.and.arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 11)
                    .background(BoostStyle.accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
            }
            .tint(BoostStyle.accent)
            Text("This creates an original design preview and JSON manifest. iPadOS does not provide a supported way for this companion app to replace textures inside the live Roblox Rivals client.")
                .font(.footnote).foregroundStyle(BoostStyle.muted)
        }
    }
}

private struct TexturePatternPreview: View {
    let style: TextureStyle
    let accent: Color
    let scale: Double
    var body: some View {
        GeometryReader { proxy in
            let side = max(10, 12 + scale * 28)
            Canvas { context, size in
                let bounds = CGRect(origin: .zero, size: size)
                context.fill(Path(bounds), with: .linearGradient(
                    Gradient(colors: [Color(red: 0.07, green: 0.09, blue: 0.13), Color(red: 0.015, green: 0.025, blue: 0.045)]),
                    startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height)
                ))
                let columns = Int(size.width / side) + 2
                let rows = Int(size.height / side) + 2
                for row in 0..<rows {
                    for column in 0..<columns {
                        let rect = CGRect(x: CGFloat(column) * side, y: CGFloat(row) * side, width: side - 1, height: side - 1)
                        switch style {
                        case .grid:
                            context.stroke(Path(rect.insetBy(dx: 2, dy: 2)), with: .color(accent.opacity(0.28)), lineWidth: 0.7)
                            if (row + column) % 5 == 0 {
                                context.fill(Path(ellipseIn: CGRect(x: rect.midX - 1.5, y: rect.midY - 1.5, width: 3, height: 3)), with: .color(accent.opacity(0.9)))
                            }
                        case .carbon:
                            let shade = (row + column).isMultiple(of: 2) ? 0.13 : 0.05
                            context.fill(Path(rect.insetBy(dx: 1, dy: 1)), with: .color(.white.opacity(shade)))
                        case .digital:
                            let opacity = (row * 7 + column * 3) % 4 == 0 ? 0.55 : 0.045
                            context.fill(Path(rect.insetBy(dx: 2, dy: 2)), with: .color(accent.opacity(opacity)))
                        case .clean:
                            context.stroke(Path(roundedRect: rect.insetBy(dx: 3, dy: 3), cornerRadius: 3), with: .color(.white.opacity(0.10)), lineWidth: 1)
                        }
                    }
                }
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("RBX / VISUAL ASSET").font(.caption2.bold()).tracking(1.8)
                    Text(style.rawValue.uppercased()).font(.title3.black())
                }
                .padding(13).foregroundStyle(.white).shadow(color: .black.opacity(0.5), radius: 8)
            }
        }
    }
}
