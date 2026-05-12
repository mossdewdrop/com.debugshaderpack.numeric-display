Shader "DebugShaderPack/Debug Numeric Display Example"
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
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Packages/com.debugshaderpack.numeric-display/Runtime/Shaders/DebugNumericDisplay.hlsl"

            fixed4 _BaseColor;
            float _RInfo;
            float _GInfo;
            float _BInfo;
            float4 _DebugOffset;
            float4 _DebugPixelSize;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 overlay = DSP_RenderDebugOverlayScreenPosAtObjectOrigin(
                    i.screenPos,
                    _RInfo,
                    _GInfo,
                    _BInfo,
                    _DebugOffset.xy,
                    _DebugPixelSize.xy
                );

                float3 color = lerp(_BaseColor.rgb, overlay.rgb, overlay.a);
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
