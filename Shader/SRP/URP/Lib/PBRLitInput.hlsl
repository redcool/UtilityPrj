#if !defined(PBR_LIT_INPUT_HLSL)
#define PBR_LIT_INPUT_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _Color;
float _NormalScale;
float _Metallic,_Smoothness,_Occlusion;
int _CutoffOn;
float _Cutoff;

int _EmissionOn;
float4 _EmissionColor;

CBUFFER_END

TEXTURE2D(_MetallicMask); SAMPLER(sampler_MetallicMask);
TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
TEXTURE2D(_MetallicMaskMap); SAMPLER(sampler_MetallicMaskMap);
TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);


float CalcAlpha(float albedoAlpha,float4 color,float cutoff,int isCutoffOn){
    float alpha = albedoAlpha * color.a;
    if(isCutoffOn){
        clip(albedoAlpha - cutoff);
    }
    return alpha;
}

float3 CalcNormal(float2 uv,TEXTURE2D_PARAM(normalMap,sampler_normalMap),float scale){
    float4 c = SAMPLE_TEXTURE2D(normalMap,sampler_normalMap,uv);
    float3 n = UnpackNormalScale(c,scale);
    return n;
}

float3 CalcEmission(float2 uv,TEXTURE2D_PARAM(map,sampler_map),float3 emissionColor,int isEmissionOn){
    if(isEmissionOn)
        return SAMPLE_TEXTURE2D(map,sampler_map,uv).xyz * emissionColor;
    return 0;
}

SurfaceData GetSurfaceData(float2 uv){
    SurfaceData data = (SurfaceData)0;
    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,uv);
    data.alpha = CalcAlpha(baseMap.w,_Color,_Cutoff,_CutoffOn);
    data.albedo = baseMap.xyz * _Color.xyz;

    float3 metallicMask = SAMPLE_TEXTURE2D(_MetallicMaskMap,sampler_MetallicMaskMap,uv);
    data. metallic = metallicMask.x * _Metallic;
    data. smoothness = metallicMask.y * _Smoothness;
    data. occlusion = lerp(1,metallicMask.z,_Occlusion);

    data. normalTS = CalcNormal(uv,_NormalMap,sampler_NormalMap,_NormalScale);
    data. emission = CalcEmission(uv,_EmissionMap,sampler_EmissionMap,_EmissionColor,_EmissionOn);
    data. specular = (float3)0;
    data.clearCoatMask = 0;
    data.clearCoatSmoothness =1;

    return data;
}

#endif //PBR_LIT_INPUT_HLSL