Shader "DebugShaderPack/URP Debug Numeric Display Example"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (0.08, 0.08, 0.08, 1.0)
        _RInfo ("R Info", Float) = 1.234
        _GInfo ("G Info", Float) = 56.789
        _BInfo ("B Info", Float) = -12.345
        _DebugOffset ("Debug Offset (Pixels)", Vector) = (0, 0, 0, 0)
        _DebugPixelSize ("Debug Pixel Size", Vector) = (24, 36, 0, 0)
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "ForwardUnlit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.debugshaderpack.numeric-display/Runtime/Shaders/DebugNumericDisplay.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float _RInfo;
                float _GInfo;
                float _BInfo;
                float4 _DebugOffset;
                float4 _DebugPixelSize;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 screenPos : TEXCOORD0;
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.screenPos = ComputeScreenPos(output.positionCS);
                return output;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                float4 overlay = DSP_RenderDebugOverlayScreenPosAtObjectOrigin(
                    input.screenPos,
                    _RInfo,
                    _GInfo,
                    _BInfo,
                    _DebugOffset.xy,
                    _DebugPixelSize.xy
                );

                float3 color = lerp(_BaseColor.rgb, overlay.rgb, overlay.a);
                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
