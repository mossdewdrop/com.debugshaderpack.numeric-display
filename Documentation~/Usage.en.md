# Debug Shader Pack Numeric Display

## Overview

- Displays three rows of debug numeric information inside a shader.
- The first row shows `RInfo` in red.
- The second row shows `GInfo` in green.
- The third row shows `BInfo` in blue.
- Each row uses the fixed format `channel letter + space + sign + 3 integer digits + decimal point + 3 fractional digits`.
- The supported display range is `-999.999` to `999.999`. Values outside the range are clamped to the nearest limit.
- The default per-character pixel size is `24x36`.
- The display anchor is the current object's origin projected into screen space, plus a user-provided pixel offset.

## Package Files

- `Runtime/Shaders/DebugNumericDisplay.hlsl`
  - Can be included directly from Unity shaders.
  - Provides standard HLSL entry points.
  - Provides Amplify Shader Editor custom function entry points with the `_float` suffix.
- `Samples~/Example/Shaders/DebugNumericDisplayExample.shader`
  - Minimal runnable example shader for the Built-in Render Pipeline.
- `Samples~/Example/Shaders/DebugNumericDisplayExampleURP.shader`
  - Minimal runnable example shader for the Universal Render Pipeline.

## Built-in Pipeline Usage

```hlsl
#include "UnityCG.cginc"
#include "Packages/com.debugshaderpack.numeric-display/Runtime/Shaders/DebugNumericDisplay.hlsl"

float4 overlay = DSP_RenderDebugOverlayScreenPosAtObjectOrigin(
    i.screenPos,
    _RInfo,
    _GInfo,
    _BInfo,
    _DebugOffset.xy,
    _DebugPixelSize.xy
);
```

Return value:

- `overlay.rgb` is the three-color numeric overlay result.
- `overlay.a` is the combined mask, which can be used to blend into the base color or emission output.

Recommended blending:

```hlsl
float3 finalColor = lerp(baseColor, overlay.rgb, overlay.a);
```

## URP Pipeline Usage

Include the URP Core library first, then include the runtime file from this package:

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.debugshaderpack.numeric-display/Runtime/Shaders/DebugNumericDisplay.hlsl"
```

In the vertex stage, only the result of `ComputeScreenPos` needs to be passed through:

```hlsl
VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
output.positionCS = positionInputs.positionCS;
output.screenPos = ComputeScreenPos(output.positionCS);
```

In the fragment stage, it is recommended to call `DSP_RenderDebugOverlayScreenPosAtObjectOrigin` directly:

```hlsl
float4 overlay = DSP_RenderDebugOverlayScreenPosAtObjectOrigin(
    input.screenPos,
    _RInfo,
    _GInfo,
    _BInfo,
    _DebugOffset.xy,
    _DebugPixelSize.xy
);
```

## Amplify Shader Editor Usage

Use a `Custom Expression` or `Custom Function` node and reference `Packages/com.debugshaderpack.numeric-display/Runtime/Shaders/DebugNumericDisplay.hlsl`.

Available functions:

- `DSP_GetObjectOriginClip_float(out float4 Out)`
- `DSP_GetWorldClip_float(float3 WorldPosition, out float4 Out)`
- `DSP_RenderDebugOverlay_float(float2 ScreenPixelPos, float4 ObjectOriginClipPos, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)`
- `DSP_RenderDebugOverlayScreenUV_float(float2 ScreenUV, float4 ObjectOriginClipPos, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)`
- `DSP_RenderDebugOverlayScreenPos_float(float4 ScreenPosition, float4 ObjectOriginClipPos, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)`
- `DSP_RenderDebugOverlayScreenPosAtObjectOrigin_float(float4 ScreenPosition, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)`
- `DSP_RenderDebugOverlayScreenPosAtWorldPosition_float(float4 ScreenPosition, float3 WorldPosition, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)`

If you are using ASE's `Screen Position` node directly, prefer:

- `DSP_RenderDebugOverlayScreenPosAtObjectOrigin_float`

If you want the display anchor to follow an arbitrary world position, you can call:

- `DSP_GetWorldClip_float`

Or use:

- `DSP_RenderDebugOverlayScreenPosAtWorldPosition_float`

## Notes

- When the object origin is behind the camera, the functions return a transparent result and nothing is displayed.
- If the input character pixel size is less than or equal to `0`, the functions fall back to the default value `24x36`.
- The current implementation only includes the character set required by this package: `R`, `G`, `B`, `0-9`, the minus sign, and the decimal point.

## Installation

- Local install: in Unity, choose `Window > Package Manager > + > Add package from disk...`, then select this package's `package.json`.
- Git install: place this package in a Git repository, then use `Add package from git URL...`.
- Local path dependency: add a `file:` dependency in the project's `Packages/manifest.json`.
