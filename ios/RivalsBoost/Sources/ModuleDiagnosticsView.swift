import SwiftUI
import BoostProbe

struct ModuleDiagnosticsView: View {
    private let report = BoostProbe.diagnostics()
    private let passed = BoostProbe.selfTest()

    var body: some View {
        ScreenShell(
            title: "Module diagnostics",
            subtitle: "Verify the signed BoostProbe framework loaded through the app's normal iOS framework loader."
        ) {
            Panel {
                HStack {
                    Label("Framework self-test", systemImage: "checkmark.shield.fill")
                        .font(.headline)
                    Spacer()
                    Text(passed ? "PASS" : "FAIL")
                        .font(.caption.bold())
                        .foregroundStyle(passed ? BoostStyle.accent : .red)
                }
                Text(passed
                     ? "BoostProbe is linked and its basic diagnostics passed."
                     : "BoostProbe did not pass its basic diagnostics.")
                    .font(.subheadline)
                    .foregroundStyle(BoostStyle.muted)
            }

            Panel {
                Text("Runtime report").font(.headline)
                ForEach(report.keys.sorted(), id: \.self) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key.uppercased())
                            .font(.caption.bold())
                            .foregroundStyle(BoostStyle.accent)
                        Text(report[key] ?? "Unavailable")
                            .font(.subheadline)
                            .textSelection(.enabled)
                    }
                }
            }

            Panel {
                Label("Scope", systemImage: "info.circle")
                    .font(.headline)
                Text("This verifies a framework shipped with Rivals Boost itself. It does not attach to, inspect, or modify Roblox or any other process.")
                    .font(.subheadline)
                    .foregroundStyle(BoostStyle.muted)
            }
        }
    }
}
