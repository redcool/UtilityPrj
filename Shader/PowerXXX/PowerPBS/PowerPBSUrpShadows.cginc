#if !defined(POWER_PBS_SHADOW_CGINC)
#define POWER_PBS_SHADOW_CGINC


// #define SHADOWS_SCREEN
#include "AutoLight.cginc"

#if defined (URP_SHADOW)

//--------- urp shadow handles
// CBUFFER_START(MainLightShadows)
    #define MAX_SHADOW_CASCADES 4
    float4x4    _MainLightWorldToShadow[MAX_SHADOW_CASCADES + 1];
    half4       _MainLightShadowOffset0;
    half4       _MainLightShadowOffset1;
    half4       _MainLightShadowOffset2;
    half4       _MainLightShadowOffset3;
    half4       _MainLightShadowParams;  // (x: shadowStrength, y: 1.0 if soft shadows, 0.0 otherwise, z: oneOverFadeDist, w: minusStartFade)
// CBUFFER_END

    half GetShadowFade(float3 positionWS)
    {
        float3 camToPixel = positionWS - _WorldSpaceCameraPos;
        float distanceCamToPixel2 = dot(camToPixel, camToPixel);

        half fade = saturate(distanceCamToPixel2 * _MainLightShadowParams.z + _MainLightShadowParams.w);
        return fade * fade;
    }

    #if defined(UNITY_NO_SCREENSPACE_SHADOWS)
        UNITY_DECLARE_SHADOWMAP(_MainLightShadowmapTexture);
        #define TRANSFER_SHADOW(a) a._ShadowCoord = mul( _MainLightWorldToShadow[0], mul( unity_ObjectToWorld, v.vertex ) );
        inline fixed unitySampleShadow (unityShadowCoord4 shadowCoord,half3 worldPos)
        {
            #if defined(SHADOWS_NATIVE)
                fixed shadow = UNITY_SAMPLE_SHADOW(_MainLightShadowmapTexture, shadowCoord.xyz);
                shadow = lerp(1,shadow,_MainLightShadowParams.x);
                half shadowFade = GetShadowFade(worldPos);
                return lerp(shadow,1,shadowFade);
            #else
                // gles 2.0
                // unityShadowCoord dist = SAMPLE_DEPTH_TEXTURE(_MainLightShadowmapTexture, shadowCoord.xy);
                // // tegra is confused if we use _LightShadowData.x directly
                // // with "ambiguous overloaded function reference max(mediump float, float)"
                // unityShadowCoord lightShadowDataX = _MainLightShadowParams.x;
                // unityShadowCoord threshold = shadowCoord.z;
                // return max(dist > threshold, lightShadowDataX);
            #endif
        }
    #else // UNITY_NO_SCREENSPACE_SHADOWS
        // UNITY_DECLARE_SCREENSPACE_SHADOWMAP(_MainLightShadowmapTexture);
        // #define TRANSFER_SHADOW(a) a._ShadowCoord = ComputeScreenPos(a.pos);
        // inline fixed unitySampleShadow (unityShadowCoord4 shadowCoord)
        // {
        //     fixed shadow = UNITY_SAMPLE_SCREEN_SHADOW(_MainLightShadowmapTexture, shadowCoord);
        //     return shadow;
        // }
    #endif

    #define SHADOW_COORDS(idx1) unityShadowCoord4 _ShadowCoord : TEXCOORD##idx1;
    #define UPR_SHADOW_ATTENUATION(a,worldPos) unitySampleShadow(a._ShadowCoord,worldPos)
#endif
#endif //POWER_PBS_SHADOW_CGINC