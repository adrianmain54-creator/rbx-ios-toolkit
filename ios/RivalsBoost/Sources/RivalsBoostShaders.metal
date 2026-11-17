#include <metal_stdlib>
using namespace metal;

// A SwiftUI colorEffect shader used only by Rivals Boost's own preview canvas.
[[ stitchable ]] half4 rivalsBoostGrade(
    float2 position,
    half4 sourceColor,
    float intensity,
    float mode
) {
    float amount = clamp(intensity, 0.0, 1.0);
    float3 rgb = float3(sourceColor.rgb);
    float luminance = dot(rgb, float3(0.2126, 0.7152, 0.0722));

    if (mode < 0.5) {
        // Neon: richer saturation and a subtle cool highlight lift.
        float3 vivid = mix(float3(luminance), rgb, 1.0 + amount * 0.85);
        vivid += float3(-0.015, 0.025, 0.075) * amount * smoothstep(0.25, 0.9, luminance);
        rgb = vivid;
    } else if (mode < 1.5) {
        // Cinematic: gentle S-curve, warm highlights, cool shadows.
        float3 contrasted = (rgb - 0.5) * (1.0 + amount * 0.65) + 0.5;
        float shadow = 1.0 - smoothstep(0.15, 0.75, luminance);
        float highlight = smoothstep(0.35, 0.95, luminance);
        contrasted += float3(0.025, 0.005, -0.025) * shadow * amount;
        contrasted += float3(0.045, 0.012, -0.018) * highlight * amount;
        rgb = contrasted;
    } else {
        // Crisp: controlled contrast and a small saturation increase.
        float3 vivid = mix(float3(luminance), rgb, 1.0 + amount * 0.28);
        rgb = (vivid - 0.5) * (1.0 + amount * 0.42) + 0.5;
    }

    return half4(half3(clamp(rgb, 0.0, 1.0)), sourceColor.a);
}
