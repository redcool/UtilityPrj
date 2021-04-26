#if !defined(SHADOWS_HLSL)
#define SHADOWS_HLSL
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

/**
    Retransform worldPos to shadowCoord when _MainLightShadowCascade is true
    otherwise use vertex shadow coord
*/
float4 TransformWorldToShadowCoord(float3 worldPos,float4 vertexShadowCoord){
    if(!_MainLightShadowCascadeOn)
        return vertexShadowCoord;
    
    float cascadeId = ComputeCascadeIndex(worldPos);
    float4 shadowCoord = mul(_MainLightWorldToShadow[cascadeId],float4(worldPos,1));
    return float4(shadowCoord.xyz,cascadeId);
}

real SampleShadowmapRealtime(TEXTURE2D_SHADOW_PARAM(ShadowMap, sampler_ShadowMap), float4 shadowCoord, ShadowSamplingData samplingData, half4 shadowParams, bool isPerspectiveProjection = true)
{
    // Compiler will optimize this branch away as long as isPerspectiveProjection is known at compile time
    if (isPerspectiveProjection)
        shadowCoord.xyz /= shadowCoord.w;

    real attenuation;
    real shadowStrength = shadowParams.x;
    real isSoftShadow = shadowParams.y;

    // TODO: We could branch on if this light has soft shadows (shadowParams.y) to save perf on some platforms.
    if(isSoftShadow){
        attenuation = SampleShadowmapFiltered(TEXTURE2D_SHADOW_ARGS(ShadowMap, sampler_ShadowMap), shadowCoord, samplingData);
    }else{
        // 1-tap hardware comparison
        attenuation = SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, shadowCoord.xyz);
    }
    attenuation = LerpWhiteTo(attenuation, shadowStrength);

    // Shadow coords that fall out of the light frustum volume must always return attenuation 1.0
    // TODO: We could use branch here to save some perf on some platforms.
    return BEYOND_SHADOW_FAR(shadowCoord) ? 1.0 : attenuation;
}

float MainLightRealtimeShadow(float4 shadowCoord,bool isShadowOn){
    if(!isShadowOn)
        return 1;
    
    ShadowSamplingData samplingData = GetMainLightShadowSamplingData();
    float4 params = GetMainLightShadowParams();
    return SampleShadowmapRealtime(_MainLightShadowmapTexture,sampler_MainLightShadowmapTexture,shadowCoord,samplingData,params,false);
}

float MixShadow(float realtimeShadow,float bakedShadow,float shadowFade,bool isMixShadow){
    if(isMixShadow){
        return min(lerp(realtimeShadow,1,shadowFade),bakedShadow);
    }
    return lerp(realtimeShadow,bakedShadow,shadowFade);
}

float MainLightShadow(float4 shadowCoord,float3 worldPos,float4 shadowMask,float4 occlusionProbeChannels,bool isShadowOn){
    float realtimeShadow = MainLightRealtimeShadow(shadowCoord,isShadowOn);

    float bakedShadow = 1;
    #if defined(CALCULATE_BAKED_SHADOWS)
        bakedShadow = BakedShadow(shadowMask,occlusionProbeChannels);
    #endif

    float shadowFade = 1;
    if(isShadowOn){
        shadowFade = GetShadowFade(worldPos);
    }
    
    #if defined(_MAIN_LIGHT_SHADOWS_CASCADE) && defined(CALCULATE_BAKED_SHADOWS)
        // shadowCoord.w represents shadow cascade index
        // in case we are out of shadow cascade we need to set shadow fade to 1.0 for correct blending
        // it is needed when realtime shadows gets cut to early during fade and causes disconnect between baked shadow
        shadowFade = shadowCoord.w == 4 ? 1.0h : shadowFade;
    #endif
    // return MixRealtimeAndBakedShadows(realtimeShadow,bakedShadow,shadowFade);

    #if defined(CALCULATE_BAKED_SHADOWS)
        bool isMixShadow = true;
    #else
        bool isMixShadow = false;
    #endif

    return MixShadow(realtimeShadow,bakedShadow,shadowFade,isMixShadow);
}

float4 SampleShadowMask(float2 shadowMaskUV){
    // #if defined(LIGHTMAP_ON) && defined(SHADOWS_SHADOWMASK)
    /**
     unity_ShadowMask,samplerunity_ShadowMask,shadowMaskuv [], unity_LightmapIndex.x]
     */
     if(_LightmapOn && _Shadows_ShadowMaskOn){
        float4 mask = SAMPLE_TEXTURE2D_LIGHTMAP(SHADOWMASK_NAME,SHADOWMASK_SAMPLER_NAME,shadowMaskUV SHADOWMASK_SAMPLE_EXTRA_ARGS);
        return mask;
     }
    // #endif
    return 1;
}

float4 CalcShadowMask(InputData inputData){
    // #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
    //     half4 shadowMask = inputData.shadowMask;
    // #elif !defined (LIGHTMAP_ON)
    //     half4 shadowMask = unity_ProbesOcclusion;
    // #else
    //     half4 shadowMask = half4(1, 1, 1, 1);
    // #endif

    float4 shadowMask = (float4)1;
    if(_LightmapOn){
        if(_Shadows_ShadowMaskOn){
            shadowMask = inputData.shadowMask;
        }else{
            shadowMask = unity_ProbesOcclusion;
        }
    }
    return shadowMask;
}

#endif //SHADOWS_HLSL