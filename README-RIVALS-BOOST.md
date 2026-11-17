# iPad Rivals Boost

A conservative Roblox-on-iPad performance and visual-customization toolkit.

## What this project does
- Documents supported iPadOS performance settings and realistic FPS limits.
- Provides clean, editable visual preset templates for use in Roblox experiences you own or have permission to edit.
- Organizes skybox, shader-look, and texture-pack assets without modifying or injecting into the Roblox client.
- Includes a validator for locally maintained FastFlag JSON. It does not bypass Roblox's allowlist or anti-cheat.

## Important limits
FastFlags are client-internal settings, not a supported iPadOS customization API. Roblox filters client settings through its allowlist, and an iPad cannot be promised 120 FPS by a JSON file. Actual frame rate depends on the iPad model, display refresh rate, thermal state, Roblox's current client, and the experience.

This repository intentionally does not include exploit code, client injection, signature bypasses, anti-cheat evasion, or claims of being undetectable. It does not ship unverified FastFlags.

## iPad performance checklist
1. Update iPadOS and Roblox.
2. Close heavy background apps and keep adequate free storage.
3. Disable Low Power Mode while gaming.
4. Avoid playing while the iPad is hot or charging in a hot environment.
5. In Roblox, lower the in-game graphics quality if frame pacing is unstable.
6. Test in the same Rivals map and record FPS/frame pacing before and after each change.

## Visual assets
The `visual-presets/` folder contains configuration examples for creators editing their own Roblox experiences in Roblox Studio. They do not alter Rivals or other players' experiences from the iPad client.

## Validation
Run:

```bash
python3 tools/validate_flags.py configs/ClientAppSettings.example.json --allowlist configs/allowlist.example.json
```

The example allowlist is intentionally empty. Add only flag names confirmed by Roblox documentation/current client allowlist. Passing this local validator does not mean Roblox will honor a flag.

## License
MIT for original scripts and documentation. Asset files added by contributors must have clear redistribution rights.
