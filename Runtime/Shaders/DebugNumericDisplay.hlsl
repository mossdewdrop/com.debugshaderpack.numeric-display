#ifndef DEBUG_NUMERIC_DISPLAY_INCLUDED
#define DEBUG_NUMERIC_DISPLAY_INCLUDED

#if !defined(UNITY_CORE_HLSL_INCLUDED) && !defined(UNIVERSAL_PIPELINE_CORE_INCLUDED)
#include "UnityCG.cginc"
#endif

static const float2 DSP_CHAR_SIZE = float2(8.0, 12.0);
static const float2 DSP_DEFAULT_PIXEL_SIZE = float2(24.0, 36.0);
static const float DSP_ROW_COUNT = 3.0;
static const float DSP_FIXED_CHAR_COUNT = 10.0;

uint4 DSP_CharSpace()
{
    return uint4(0x000000u, 0x000000u, 0x000000u, 0x000000u);
}

uint4 DSP_CharMinus()
{
    return uint4(0x000000u, 0x0000FEu, 0x000000u, 0x000000u);
}

uint4 DSP_CharDot()
{
    return uint4(0x000000u, 0x000000u, 0x000038u, 0x380000u);
}

uint4 DSP_Char0()
{
    return uint4(0x007CC6u, 0xD6D6D6u, 0xD6D6C6u, 0x7C0000u);
}

uint4 DSP_Char1()
{
    return uint4(0x001030u, 0xF03030u, 0x303030u, 0xFC0000u);
}

uint4 DSP_Char2()
{
    return uint4(0x0078CCu, 0xCC0C18u, 0x3060CCu, 0xFC0000u);
}

uint4 DSP_Char3()
{
    return uint4(0x0078CCu, 0x0C0C38u, 0x0C0CCCu, 0x780000u);
}

uint4 DSP_Char4()
{
    return uint4(0x000C1Cu, 0x3C6CCCu, 0xFE0C0Cu, 0x1E0000u);
}

uint4 DSP_Char5()
{
    return uint4(0x00FCC0u, 0xC0C0F8u, 0x0C0CCCu, 0x780000u);
}

uint4 DSP_Char6()
{
    return uint4(0x003860u, 0xC0C0F8u, 0xCCCCCCu, 0x780000u);
}

uint4 DSP_Char7()
{
    return uint4(0x00FEC6u, 0xC6060Cu, 0x183030u, 0x300000u);
}

uint4 DSP_Char8()
{
    return uint4(0x0078CCu, 0xCCEC78u, 0xDCCCCCu, 0x780000u);
}

uint4 DSP_Char9()
{
    return uint4(0x0078CCu, 0xCCCC7Cu, 0x181830u, 0x700000u);
}

uint4 DSP_CharB()
{
    return uint4(0x00FC66u, 0x66667Cu, 0x666666u, 0xFC0000u);
}

uint4 DSP_CharG()
{
    return uint4(0x003C66u, 0xC6C0C0u, 0xCEC666u, 0x3E0000u);
}

uint4 DSP_CharR()
{
    return uint4(0x00FC66u, 0x66667Cu, 0x6C6666u, 0xE60000u);
}

uint4 DSP_GetDigitSprite(int digit)
{
    switch (digit)
    {
        case 0: return DSP_Char0();
        case 1: return DSP_Char1();
        case 2: return DSP_Char2();
        case 3: return DSP_Char3();
        case 4: return DSP_Char4();
        case 5: return DSP_Char5();
        case 6: return DSP_Char6();
        case 7: return DSP_Char7();
        case 8: return DSP_Char8();
        default: return DSP_Char9();
    }
}

uint4 DSP_GetLabelSprite(int rowIndex)
{
    if (rowIndex == 0)
    {
        return DSP_CharR();
    }

    if (rowIndex == 1)
    {
        return DSP_CharG();
    }

    return DSP_CharB();
}

float DSP_ExtractBit24(uint value, int bitIndex)
{
    if (bitIndex < 0 || bitIndex > 23)
    {
        return 0.0;
    }

    return (float)((value >> bitIndex) & 1u);
}

float DSP_SampleSprite(uint4 sprite, float2 glyphPixel)
{
    int2 pixel = (int2)floor(glyphPixel);

    if (pixel.x < 0 || pixel.y < 0 || pixel.x >= 8 || pixel.y >= 12)
    {
        return 0.0;
    }

    int bit = (7 - pixel.x) + pixel.y * 8;

    if (bit >= 72)
    {
        return DSP_ExtractBit24(sprite.x, bit - 72);
    }

    if (bit >= 48)
    {
        return DSP_ExtractBit24(sprite.y, bit - 48);
    }

    if (bit >= 24)
    {
        return DSP_ExtractBit24(sprite.z, bit - 24);
    }

    return DSP_ExtractBit24(sprite.w, bit);
}

float DSP_DrawChar(uint4 sprite, float2 screenPixelPos, inout float2 cursorPixel, float2 charPixelSize)
{
    float2 localPixel = screenPixelPos - cursorPixel;
    float2 glyphPixel = localPixel * (DSP_CHAR_SIZE / charPixelSize);
    float coverage = DSP_SampleSprite(sprite, glyphPixel);
    cursorPixel.x += charPixelSize.x;
    return coverage;
}

float3 DSP_FormatValue(float value)
{
    float magnitude = min(abs(value), 999.999);
    int integerPart = min((int)floor(magnitude + 1e-6), 999);
    int fractionalPart = min((int)floor(frac(magnitude) * 1000.0 + 1e-4), 999);
    float signValue = value < 0.0 ? -1.0 : 1.0;
    return float3((float)integerPart, (float)fractionalPart, signValue);
}

float DSP_DrawFixedWidthInteger(float2 screenPixelPos, inout float2 cursorPixel, float2 charPixelSize, int integerPart)
{
    float coverage = 0.0;
    int hundreds = integerPart / 100;
    int tens = (integerPart / 10) % 10;
    int ones = integerPart % 10;

    coverage += DSP_DrawChar(hundreds > 0 ? DSP_GetDigitSprite(hundreds) : DSP_CharSpace(), screenPixelPos, cursorPixel, charPixelSize);
    coverage += DSP_DrawChar((hundreds > 0 || tens > 0) ? DSP_GetDigitSprite(tens) : DSP_CharSpace(), screenPixelPos, cursorPixel, charPixelSize);
    coverage += DSP_DrawChar(DSP_GetDigitSprite(ones), screenPixelPos, cursorPixel, charPixelSize);

    return coverage;
}

float DSP_DrawFixedWidthFraction(float2 screenPixelPos, inout float2 cursorPixel, float2 charPixelSize, int fractionalPart)
{
    float coverage = 0.0;
    int hundreds = fractionalPart / 100;
    int tens = (fractionalPart / 10) % 10;
    int ones = fractionalPart % 10;

    coverage += DSP_DrawChar(DSP_GetDigitSprite(hundreds), screenPixelPos, cursorPixel, charPixelSize);
    coverage += DSP_DrawChar(DSP_GetDigitSprite(tens), screenPixelPos, cursorPixel, charPixelSize);
    coverage += DSP_DrawChar(DSP_GetDigitSprite(ones), screenPixelPos, cursorPixel, charPixelSize);

    return coverage;
}

float DSP_DrawRow(float2 screenPixelPos, float2 rowOriginPixel, float2 charPixelSize, float value, int rowIndex)
{
    float3 formatted = DSP_FormatValue(value);
    int integerPart = (int)formatted.x;
    int fractionalPart = (int)formatted.y;
    bool isNegative = formatted.z < 0.0;

    float2 cursorPixel = rowOriginPixel;
    float coverage = 0.0;

    coverage += DSP_DrawChar(DSP_GetLabelSprite(rowIndex), screenPixelPos, cursorPixel, charPixelSize);
    coverage += DSP_DrawChar(DSP_CharSpace(), screenPixelPos, cursorPixel, charPixelSize);
    coverage += DSP_DrawChar(isNegative ? DSP_CharMinus() : DSP_CharSpace(), screenPixelPos, cursorPixel, charPixelSize);
    coverage += DSP_DrawFixedWidthInteger(screenPixelPos, cursorPixel, charPixelSize, integerPart);
    coverage += DSP_DrawChar(DSP_CharDot(), screenPixelPos, cursorPixel, charPixelSize);
    coverage += DSP_DrawFixedWidthFraction(screenPixelPos, cursorPixel, charPixelSize, fractionalPart);

    return saturate(coverage);
}

float2 DSP_SanitizePixelSize(float2 pixelSize)
{
    float2 safePixelSize = pixelSize;

    if (safePixelSize.x <= 0.0 || safePixelSize.y <= 0.0)
    {
        safePixelSize = DSP_DEFAULT_PIXEL_SIZE;
    }

    return safePixelSize;
}

float2 DSP_ClipToScreenPixel(float4 clipPosition)
{
    float2 ndc = clipPosition.xy / max(clipPosition.w, 1e-6);
    float2 uv = ndc * 0.5 + 0.5;

    #if UNITY_UV_STARTS_AT_TOP
    uv.y = 1.0 - uv.y;
    #endif

    return uv * _ScreenParams.xy;
}

float2 DSP_ScreenPosToScreenPixel(float4 screenPosition)
{
    float2 screenUV = screenPosition.xy / max(screenPosition.w, 1e-6);
    return screenUV * _ScreenParams.xy;
}

float4 DSP_RenderDebugOverlay(float2 screenPixelPos, float4 objectOriginClipPos, float rInfo, float gInfo, float bInfo, float2 pixelOffset, float2 pixelSize)
{
    if (objectOriginClipPos.w <= 0.0)
    {
        return 0.0;
    }

    float2 charPixelSize = DSP_SanitizePixelSize(pixelSize);
    float2 anchorPixel = DSP_ClipToScreenPixel(objectOriginClipPos) + pixelOffset;
    float2 blockPixelSize = float2(DSP_FIXED_CHAR_COUNT * charPixelSize.x, DSP_ROW_COUNT * charPixelSize.y);
    float2 topLeftPixel = anchorPixel - blockPixelSize * 0.5;

    // Keep the visible row order top-to-bottom as R, G, then B.
    float rRow = DSP_DrawRow(screenPixelPos, topLeftPixel + float2(0.0, charPixelSize.y * 2.0), charPixelSize, rInfo, 0);
    float gRow = DSP_DrawRow(screenPixelPos, topLeftPixel + float2(0.0, charPixelSize.y * 1.0), charPixelSize, gInfo, 1);
    float bRow = DSP_DrawRow(screenPixelPos, topLeftPixel + float2(0.0, charPixelSize.y * 0.0), charPixelSize, bInfo, 2);

    float3 rgb = float3(rRow, gRow, bRow);
    float alpha = saturate(max(rRow, max(gRow, bRow)));
    return float4(rgb, alpha);
}

float4 DSP_RenderDebugOverlayScreenUV(float2 screenUV, float4 objectOriginClipPos, float rInfo, float gInfo, float bInfo, float2 pixelOffset, float2 pixelSize)
{
    return DSP_RenderDebugOverlay(screenUV * _ScreenParams.xy, objectOriginClipPos, rInfo, gInfo, bInfo, pixelOffset, pixelSize);
}

float4 DSP_RenderDebugOverlayScreenPos(float4 screenPosition, float4 objectOriginClipPos, float rInfo, float gInfo, float bInfo, float2 pixelOffset, float2 pixelSize)
{
    return DSP_RenderDebugOverlay(DSP_ScreenPosToScreenPixel(screenPosition), objectOriginClipPos, rInfo, gInfo, bInfo, pixelOffset, pixelSize);
}

float4 DSP_GetObjectOriginClipPosition()
{
    #if defined(UNITY_CORE_HLSL_INCLUDED) || defined(UNIVERSAL_PIPELINE_CORE_INCLUDED)
    return TransformObjectToHClip(float3(0.0, 0.0, 0.0));
    #else
    return UnityObjectToClipPos(float4(0.0, 0.0, 0.0, 1.0));
    #endif
}

float4 DSP_GetWorldClipPosition(float3 worldPosition)
{
    #if defined(UNITY_CORE_HLSL_INCLUDED) || defined(UNIVERSAL_PIPELINE_CORE_INCLUDED)
    return TransformWorldToHClip(worldPosition);
    #else
    return mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0));
    #endif
}

float4 DSP_RenderDebugOverlayScreenPosAtObjectOrigin(float4 screenPosition, float rInfo, float gInfo, float bInfo, float2 pixelOffset, float2 pixelSize)
{
    return DSP_RenderDebugOverlayScreenPos(screenPosition, DSP_GetObjectOriginClipPosition(), rInfo, gInfo, bInfo, pixelOffset, pixelSize);
}

float4 DSP_RenderDebugOverlayScreenPosAtWorldPosition(float4 screenPosition, float3 worldPosition, float rInfo, float gInfo, float bInfo, float2 pixelOffset, float2 pixelSize)
{
    return DSP_RenderDebugOverlayScreenPos(screenPosition, DSP_GetWorldClipPosition(worldPosition), rInfo, gInfo, bInfo, pixelOffset, pixelSize);
}

void DSP_RenderDebugOverlay_float(float2 ScreenPixelPos, float4 ObjectOriginClipPos, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)
{
    Out = DSP_RenderDebugOverlay(ScreenPixelPos, ObjectOriginClipPos, RInfo, GInfo, BInfo, PixelOffset, PixelSize);
}

void DSP_RenderDebugOverlayScreenUV_float(float2 ScreenUV, float4 ObjectOriginClipPos, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)
{
    Out = DSP_RenderDebugOverlayScreenUV(ScreenUV, ObjectOriginClipPos, RInfo, GInfo, BInfo, PixelOffset, PixelSize);
}

void DSP_RenderDebugOverlayScreenPos_float(float4 ScreenPosition, float4 ObjectOriginClipPos, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)
{
    Out = DSP_RenderDebugOverlayScreenPos(ScreenPosition, ObjectOriginClipPos, RInfo, GInfo, BInfo, PixelOffset, PixelSize);
}

void DSP_RenderDebugOverlayScreenPosAtObjectOrigin_float(float4 ScreenPosition, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)
{
    Out = DSP_RenderDebugOverlayScreenPosAtObjectOrigin(ScreenPosition, RInfo, GInfo, BInfo, PixelOffset, PixelSize);
}

void DSP_RenderDebugOverlayScreenPosAtWorldPosition_float(float4 ScreenPosition, float3 WorldPosition, float RInfo, float GInfo, float BInfo, float2 PixelOffset, float2 PixelSize, out float4 Out)
{
    Out = DSP_RenderDebugOverlayScreenPosAtWorldPosition(ScreenPosition, WorldPosition, RInfo, GInfo, BInfo, PixelOffset, PixelSize);
}

void DSP_GetObjectOriginClip_float(out float4 Out)
{
    Out = DSP_GetObjectOriginClipPosition();
}

void DSP_GetWorldClip_float(float3 WorldPosition, out float4 Out)
{
    Out = DSP_GetWorldClipPosition(WorldPosition);
}

#endif
