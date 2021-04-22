#if !defined(PBR_LIT_FORWARD_PASS_HLSL)
#define PBR_LIT_FORWARD_PASS_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes{
    float4 pos:POSITION;
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
    float2 uv:TEXCOORD;
    float2 uv1 :TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings{
    float4 pos : SV_POSITION;
    float2 uv:TEXCOORD0;
    float3 uv1:TEXCOORD1; // sh,lightmap
    float4 tSpace0:TEXCOORD2;
    float4 tSpace1:TEXCOORD3;
    float4 tSpace2:TEXCOORD4;
    float4 vertexLightAndFogFactor:TEXCOORD5;
    float4 shadowCoord:TEXCOORD6;


    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings vert(Attributes input){
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input,output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 worldPos = TransformObjectToWorld(input.pos);
    float3 worldNormal = TransformObjectToWorldNormal(input.normal);
    float sign = input.tangent.w * GetOddNegativeScale();
    float3 worldTangent = TransformObjectToWorldDir(input.tangent);
    float3 worldBinormal = cross(worldNormal,worldTangent)  * sign;
    output.tSpace0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
    output.tSpace1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
    output.tSpace2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

    output.uv = TRANSFORM_TEX(input.uv,_BaseMap);
    float4 clipPos = TransformWorldToHClip(worldPos);

    float fogFactor = ComputeFogFactor(clipPos.z);
    float3 vertexLight = VertexLighting(worldPos,worldNormal);
    output.vertexLightAndFogFactor = float4(vertexLight,fogFactor);

    OUTPUT_LIGHTMAP_UV(input.uv1,unity_LightmapST,output.uv1);


    output.pos = clipPos;

    return output;
}

InputData GetInputData(Varyings input,half3 normalTS){
    float3 worldPos = float3(input.tSpace0.w,input.tSpace1.w,input.tSpace2.w);
    float3 normal = float3(
        dot(normalTS,float3(input.tSpace0.x,input.tSpace1.x,input.tSpace2.x)),
        dot(normalTS,float3(input.tSpace0.y,input.tSpace1.y,input.tSpace2.y)),
        dot(normalTS,float3(input.tSpace0.z,input.tSpace1.z,input.tSpace2.z))
    );
    float3 viewDir = SafeNormalize(_WorldSpaceCameraPos - worldPos);
    float4 shadowCoord = (float4)0;
    float fogFactor = input.vertexLightAndFogFactor.w;
    float3 vertexLight = input.vertexLightAndFogFactor.xyz;
    float3 bakedGI = SampleSH(normal);
    
    InputData data = (InputData)0;
    data.positionWS = worldPos;
    data.normalWS = normal;
    data.viewDirectionWS = viewDir;
    data.shadowCoord = shadowCoord;
    data.fogCoord = fogFactor;
    data.vertexLighting = vertexLight;
    data.bakedGI = bakedGI;
    data.normalizedScreenSpaceUV = (float2)0;
    data.shadowMask = 0;
    return data;
}

float4 frag(Varyings input):SV_Target{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    SurfaceData surfaceData = GetSurfaceData(input.uv);
    InputData inputData = GetInputData(input,surfaceData.normalTS);
    float4 color = UniversalFragmentPBR(inputData,surfaceData);
    color.rgb = MixFog(color.rgb,inputData.fogCoord);
    // color.a = OutputAlpha(color.a,_SurfaceType)

    return color;
}

#endif //PBR_LIT_FORWARD_PASS_HLSL