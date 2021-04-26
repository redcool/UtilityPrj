#if !defined(LIGHTING_HLSL)
#define LIGHTING_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Shadows.hlsl"
#include "GI.hlsl"

/***
// Light 
***/

Light GetMainLight(float4 shadowCoord,float3 worldPos,float4 shadowMask,bool isShadowOn){
    Light light;
    light.direction = _MainLightPosition.xyz;
    light.color = _MainLightColor.rgb;
    light.distanceAttenuation = unity_LightData.z; // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
    light.shadowAttenuation = MainLightShadow(shadowCoord,worldPos,shadowMask,_MainLightOcclusionProbes,isShadowOn);
    return light;
}

// float3 SafeNormalize(float3 v){
//     float len = max(0.0000001,dot(v,v));
//     return v/rsqrt(len);
// }

void InitBRDFData(SurfaceInputData surfaceInputData,inout float alpha,out BRDFData brdfData){
    SurfaceData surfaceData = surfaceInputData.surfaceData;

    float oneMinusReflectivityMetallic = OneMinusReflectivityMetallic(surfaceData.metallic);
    brdfData.reflectivity = 1 - oneMinusReflectivityMetallic;
    brdfData.diffuse = surfaceData.albedo * oneMinusReflectivityMetallic;
    brdfData.specular = lerp(kDieletricSpec.rgb,surfaceData.albedo,surfaceData.metallic);
    brdfData.perceptualRoughness = 1 - surfaceData.smoothness;
    brdfData.roughness = max(HALF_MIN_SQRT,brdfData.perceptualRoughness * brdfData.perceptualRoughness);
    brdfData.roughness2 = max(brdfData.roughness * brdfData.roughness,HALF_MIN);
    brdfData.grazingTerm = saturate(surfaceData.smoothness + brdfData.reflectivity); // (smoothness + metallic)
    brdfData.normalizationTerm = brdfData.roughness * 4 + 2; // mct factor
    brdfData.roughness2MinusOne = brdfData.roughness2 - 1; // mct factor

    if(surfaceInputData.isAlphaPremultiply){
        brdfData.diffuse *= alpha;
        alpha = alpha * oneMinusReflectivityMetallic + brdfData.reflectivity; //lerp(a,1,m)
    }
}

/***
    Minimalist cook torrance
    r2/(d*d * lh*lh *(4r+2))
***/
float3 CalcDirectSpecularTerm(float r/*roughness*/,float3 lightDir,float3 viewDir,float3 normal){
    float3 h = SafeNormalize(lightDir + viewDir);
    float nh = saturate(dot(normal,h));
    float lh = saturate(dot(lightDir,h));

    float r2 = r * r;
    float d = nh * nh * (r2-1)+1;
    float specTerm = r2/( d * d * max(0.1, lh * lh) * ( 4 * r + 2 ));

    #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
        specTerm = clamp(specTerm,0,100);
    #endif
    return specTerm;
}



float3 CalcPBRLighting(BRDFData brdfData,float3 lightColor,float3 lightDir,float lightAtten,
    float3 normal,float3 viewDir){
    float nl = saturate(dot(normal,lightDir));
    float3 radiance = lightColor * lightAtten * nl; // light's color

    float3 brdf = brdfData.diffuse;
    brdf += brdfData.specular * CalcDirectSpecularTerm(brdfData.roughness,lightDir,viewDir,normal);
    return brdf * radiance;
}


float4 CalcPBR(SurfaceInputData data){
    SurfaceData surfaceData = data.surfaceData;
    InputData inputData = data.inputData;

    BRDFData brdfData;
    InitBRDFData(data,surfaceData.alpha/*inout*/,brdfData/*out*/);

    float4 shadowMask = CalcShadowMask(inputData);
    Light mainLight = GetMainLight(inputData.shadowCoord,inputData.positionWS,shadowMask,data.isShadowOn);

    // MixRealtimeAndBakedGI(mainLight,inputData.normalWS,inputData.bakedGI);
    half3 color = CalcGI(brdfData,inputData.bakedGI,surfaceData.occlusion,inputData.normalWS,inputData.viewDirectionWS);
    color += CalcPBRLighting(brdfData,mainLight.color,mainLight.direction,mainLight.distanceAttenuation * mainLight.shadowAttenuation,inputData.normalWS,inputData.viewDirectionWS);
    color += surfaceData.emission;

    return float4(color,surfaceData.alpha);
}

#endif //LIGHTING_HLSL