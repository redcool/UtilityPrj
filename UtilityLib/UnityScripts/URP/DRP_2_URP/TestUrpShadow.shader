Shader "Unlit/TestShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    CGINCLUDE
    #define MAX_SHADOW_CASCADES 4
    float4x4    _MainLightWorldToShadow[MAX_SHADOW_CASCADES + 1];
    float4       _MainLightShadowParams;  // (x: shadowStrength, y: 1.0 if soft shadows, 0.0 otherwise, z: oneOverFadeDist, w: minusStartFade)
// CBUFFER_END

    float GetShadowFade(float3 positionWS)
    {
        float3 camToPixel = positionWS - _WorldSpaceCameraPos;
        float distanceCamToPixel2 = dot(camToPixel, camToPixel);

        float fade = saturate(distanceCamToPixel2 * _MainLightShadowParams.z + _MainLightShadowParams.w);
        return fade * fade;
    }

    UNITY_DECLARE_SHADOWMAP(_MainLightShadowmapTexture);
    #define TRANSFER_SHADOW(a) a._ShadowCoord = mul( _MainLightWorldToShadow[0], mul( unity_ObjectToWorld, v.vertex ) );
    inline float CalcShadow (float4 shadowCoord,float3 worldPos)
    {
        // #if !defined(_MAIN_LIGHT_SHADOWS)
        //     return 1;
        // #endif

        #if defined(SHADOWS_NATIVE)
            float shadow = UNITY_SAMPLE_SHADOW(_MainLightShadowmapTexture, shadowCoord.xyz);
                //float shadow = _MainLightShadowmapTexture.SampleCmpLevelZero(sampler_MainLightShadowmapTexture,shadowCoord.xy,shadowCoord.z);
            shadow = lerp(1,shadow,_MainLightShadowParams.x);
            float shadowFade = GetShadowFade(worldPos);
            return lerp(shadow,1,shadowFade);
        #else
            // gles 2.0 , not supported
            return 1;
        #endif
    }
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 _ShadowCoord:TEXCOORD1;
                float3 worldPos:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                TRANSFER_SHADOW(o);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float atten = CalcShadow(i._ShadowCoord,i.worldPos);
                return atten;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    fallback "Diffuse"
}
