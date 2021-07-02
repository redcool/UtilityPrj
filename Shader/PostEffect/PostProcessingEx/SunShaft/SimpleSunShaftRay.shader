Shader "Hidden/Custom/SimpleSunShaftRay"
{
    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        float _Blend;

        float2 _ScreenLightPos;
        float _Density;
        float _Decay;
        float _Exposure;

        struct Attributes{
            float4 vertex:POSITION;
        };

        struct Varyings{
            float4 vertex:SV_POSITION;
            float4 uv0:TEXCOORD0;
            float4 uv1:TEXCOORD1;
            float4 uv2:TEXCOORD2;
            float4 uv3:TEXCOORD3;
        };

        Varyings Vert(Attributes v){
            Varyings o = (Varyings)0;
            o.vertex = float4(v.vertex.xy,0,1);
            float2 uv = TransformTriangleVertexToUV(v.vertex.xy);
            #if UNITY_UV_STARTS_AT_TOP
                uv = uv * float2(1.0, -1.0) + float2(0.0, 1.0);
            #endif
            float2 deltaUV = uv - _ScreenLightPos.xy;
            deltaUV *= 1.0/8 * _Density;

            uv -= deltaUV;
            o.uv0.xy = uv;
            uv -= deltaUV;
            o.uv0.zw = uv;

            uv -= deltaUV;
            o.uv1.xy = uv;
            uv -= deltaUV;
            o.uv1.zw = uv;

            uv -= deltaUV;
            o.uv2.xy = uv;
            uv -= deltaUV;
            o.uv2.zw = uv;

            uv -= deltaUV;
            o.uv3.xy = uv;
            uv -= deltaUV;
            o.uv3.zw = uv;

            return o;
        }
        float4 Frag(Varyings i) : SV_Target
        {
            float illumin =1;
            float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv0.xy) * illumin;
            illumin *=_Decay;
            color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv0.zw) * illumin;
            illumin *=_Decay;

            color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv1.xy) * illumin;
            illumin *=_Decay;
            color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv1.zw) * illumin;
            illumin *=_Decay;

            color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv2.xy) * illumin;
            illumin *=_Decay;
            color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv2.zw) * illumin;
            illumin *=_Decay;

            color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv3.xy) * illumin;
            illumin *=_Decay;
            color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv3.zw) * illumin;
            illumin *=_Decay;
            
            color /= 8;
            return float4(color.rgb * _Exposure,1);
        }

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM

                #pragma vertex Vert
                #pragma fragment Frag

            ENDHLSL
        }
    }
}