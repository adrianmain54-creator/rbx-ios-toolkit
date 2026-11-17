import Foundation
import Combine

@MainActor
final class ProfileStore: ObservableObject {
    @Published private(set) var profiles: [VisualProfile] = []
    @Published var selectedProfileID: UUID?

    private let storageKey = "aoidfflag.visualProfiles.v1"

    init() {
        load()
        if profiles.isEmpty {
            profiles = VisualProfile.presets
            selectedProfileID = profiles.first?.id
            save()
        } else if selectedProfileID == nil {
            selectedProfileID = profiles.first?.id
        }
    }

    var selectedProfile: VisualProfile? {
        profiles.first { $0.id == selectedProfileID }
    }

    func select(_ profile: VisualProfile) {
        selectedProfileID = profile.id
    }

    func update(_ profile: VisualProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index] = profile
        save()
    }

    func addProfile() {
        let profile = VisualProfile(name: "New Profile")
        profiles.append(profile)
        selectedProfileID = profile.id
        save()
    }

    func duplicate(_ profile: VisualProfile) {
        var copy = profile
        copy.id = UUID()
        copy.name += " Copy"
        profiles.append(copy)
        selectedProfileID = copy.id
        save()
    }

    func resetPresets() {
        profiles = VisualProfile.presets
        selectedProfileID = profiles.first?.id
        save()
    }

    func exportData(for profile: VisualProfile) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(profile)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([VisualProfile].self, from: data)
        else { return }
        profiles = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
