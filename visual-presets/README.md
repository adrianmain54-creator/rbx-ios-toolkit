# Visual presets (Roblox Studio creator workflow)

These presets are for experiences you own or are authorized to edit. They are not client-side shaders for the live Rivals game.

## Skybox
In Roblox Studio, add a Sky object under Lighting and assign six licensed images to SkyboxBk, SkyboxDn, SkyboxFt, SkyboxLf, SkyboxRt, and SkyboxUp. Keep a record of asset IDs and licenses.

## Shader-style looks
Roblox experiences do not accept arbitrary post-processing shader code from a player client. For your own experience, use supported Lighting effects such as ColorCorrectionEffect, BloomEffect, SunRaysEffect, and Atmosphere. Keep effects subtle on mobile to protect frame time.

## Included profiles
- performance: restrained effects and lower visual cost.
- balanced: moderate color grading and atmosphere.
- cinematic: stronger effects; not recommended for competitive mobile play.

See profiles.json for editable values.
