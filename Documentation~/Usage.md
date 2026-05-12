# Debug Shader Pack Numeric Display

## 功能说明

- 在 Shader 中显示三行调试数字信息。
- 第一行显示 `RInfo`，颜色为红色。
- 第二行显示 `GInfo`，颜色为绿色。
- 第三行显示 `BInfo`，颜色为蓝色。
- 每行格式固定为 `通道字母 + 空格 + 符号位 + 3 位整数 + 小数点 + 3 位小数`。
- 最大显示范围为 `-999.999` 到 `999.999`，超出范围会截断到边界值。
- 默认单字符像素大小为 `24x36`。
- 显示锚点为当前对象原点投影到屏幕后的像素位置，再叠加用户输入的像素偏移。

## 包内文件

- `Runtime/Shaders/DebugNumericDisplay.hlsl`
  - 可直接在 Unity Shader 中 `#include`。
  - 提供普通 HLSL 调用接口。
  - 提供带 `_float` 后缀的 Amplify Shader Editor 自定义函数接口。
- `Samples~/Example/Shaders/DebugNumericDisplayExample.shader`
  - Built-in Render Pipeline 最小可运行示例 Shader。
- `Samples~/Example/Shaders/DebugNumericDisplayExampleURP.shader`
  - Universal Render Pipeline 最小可运行示例 Shader。

## Built-in 管线用法

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

返回值说明：

- `overlay.rgb` 为三色数字叠加结果。
- `overlay.a` 为整体遮罩，可用于混合到底色或发光输出。

推荐混合方式：

```hlsl
float3 finalColor = lerp(baseColor, overlay.rgb, overlay.a);
```

## URP 管线用法

先引入 URP Core，再引入本包的运行时文件：

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.debugshaderpack.numeric-display/Runtime/Shaders/DebugNumericDisplay.hlsl"
```

顶点阶段只需要保留 `ComputeScreenPos` 的结果：

```hlsl
VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
output.positionCS = positionInputs.positionCS;
output.screenPos = ComputeScreenPos(output.positionCS);
```

片元阶段推荐直接使用 `DSP_RenderDebugOverlayScreenPosAtObjectOrigin`：

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

## Amplify Shader Editor 用法

建议使用 `Custom Expression` 或 `Custom Function` 节点，并引用 `Packages/com.debugshaderpack.numeric-display/Runtime/Shaders/DebugNumericDisplay.hlsl`。

可用函数：

- `DSP_GetObjectOriginClip_float(out float4 Out)`
- `DSP_GetWorldClip_float(float3 WorldPosition, out float4 Out)`
- `DSP_RenderDebugOverlay_float(float2 ScreenPixelPos, float4 ObjectOriginClipPos, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)`
- `DSP_RenderDebugOverlayScreenUV_float(float2 ScreenUV, float4 ObjectOriginClipPos, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)`
- `DSP_RenderDebugOverlayScreenPos_float(float4 ScreenPosition, float4 ObjectOriginClipPos, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)`
- `DSP_RenderDebugOverlayScreenPosAtObjectOrigin_float(float4 ScreenPosition, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)`
- `DSP_RenderDebugOverlayScreenPosAtWorldPosition_float(float4 ScreenPosition, float3 WorldPosition, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)`

如果直接使用 ASE 的 `Screen Position` 节点，优先使用：

- `DSP_RenderDebugOverlayScreenPosAtObjectOrigin_float`

如果希望把显示锚点绑定到任意世界坐标，可先调用：

- `DSP_GetWorldClip_float`

或直接使用：

- `DSP_RenderDebugOverlayScreenPosAtWorldPosition_float`

## 注意事项

- 当对象原点在相机后方时，函数返回透明结果，不进行显示。
- 如果传入的字符像素大小小于等于 `0`，函数会回退到默认值 `24x36`。
- 当前实现只包含需求中实际需要的字符编码：`R`、`G`、`B`、`0-9`、负号和小数点。

## 安装方式

- 本地安装：Unity `Window > Package Manager > + > Add package from disk...`，选择本包中的 `package.json`。
- Git 安装：将本包放入 Git 仓库后，通过 `Add package from git URL...` 引入。
- 本地路径依赖：在项目 `Packages/manifest.json` 中添加 `file:` 依赖。
