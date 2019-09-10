#ifndef POSTLIB_HLSL
#define POSTLIB_HLSL

#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"


float4 SampleBox(Texture2D tex,SamplerState state,float4 texel,float2 uv, float delta) {
    float2 p = texel.xy * delta;
    
const float2 boxCoords[] = {
    {-1,-1},{0,-1},{1,-1},
    {-1,0,},{0,0},{1,0},
    {-1,1},{0,1},{1,1}
};
const float boxWeights[] = {
    0.09,0.12,0.09,
    0.12,0.15,0.12,
    0.09,0.12,0.09
};

    float4 c = (float4)0;
    for(int i=0;i<9;i++){
        c += SAMPLE_TEXTURE2D(tex,state,uv + boxCoords[i] * p) * boxWeights[i];
    }
    return c;
}

float4 SampleBox(Texture2D tex,SamplerState state,float4 texel,float2 uv, float delta,float sideWeight,float centerWeight) {
    float2 p = texel.xy * delta;
    float4 c = SAMPLE_TEXTURE2D(tex,state,uv + float2(-1,-1) * p) * sideWeight;
    c += SAMPLE_TEXTURE2D(tex,state,uv + float2(1,-1) * p) * sideWeight;
    c += SAMPLE_TEXTURE2D(tex,state,uv + float2(-1,1) * p) * sideWeight;
    c += SAMPLE_TEXTURE2D(tex,state,uv + float2(1,1) * p) * sideWeight;
    //c += SAMPLE_TEXTURE2D(tex,state,uv) * centerWeight;
    return c;
}

float Gray(float3 c){
    return dot(float3(0.2,0.7,0.07),c);
}

#endif // POSTLIB_HLSL
