import SwiftUI

@main
struct AoidFFlagApp: App {
    @StateObject private var store = ProfileStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
