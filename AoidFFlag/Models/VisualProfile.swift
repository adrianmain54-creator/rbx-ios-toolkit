import Foundation

struct VisualProfile: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var game: String
    var textureQuality: Int
    var antiAliasing: Int
    var saturation: Double
    var contrast: Double
    var brightness: Double
    var skyboxPreset: String
    var notes: String

    init(
        id: UUID = UUID(),
        name: String,
        game: String = "Rivals",
        textureQuality: Int = 2,
        antiAliasing: Int = 0,
        saturation: Double = 1,
        contrast: Double = 1,
        brightness: Double = 1,
        skyboxPreset: String = "Default",
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.game = game
        self.textureQuality = textureQuality
        self.antiAliasing = antiAliasing
        self.saturation = saturation
        self.contrast = contrast
        self.brightness = brightness
        self.skyboxPreset = skyboxPreset
        self.notes = notes
    }

    static let presets: [VisualProfile] = [
        VisualProfile(
            name: "Competitive",
            textureQuality: 2,
            antiAliasing: 0,
            saturation: 1,
            contrast: 1.08,
            brightness: 1.02,
            skyboxPreset: "Default",
            notes: "A restrained profile intended to keep the image clear."
        ),
        VisualProfile(
            name: "Performance",
            textureQuality: 0,
            antiAliasing: 0,
            saturation: 0.9,
            contrast: 1,
            brightness: 1,
            skyboxPreset: "Default",
            notes: "Lower requested visual quality; actual game behavior depends on Roblox."
        ),
        VisualProfile(
            name: "Visual",
            textureQuality: 3,
            antiAliasing: 4,
            saturation: 1.2,
            contrast: 1.12,
            brightness: 1.05,
            skyboxPreset: "Blue Hour",
            notes: "A vivid visual preference profile."
        )
    ]
}
