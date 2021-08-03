#ifndef POSTLIB_HLSL
#define POSTLIB_HLSL

#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

float4 SampleBox(Texture2D tex, SamplerState state, float4 texel, float2 uv, float delta) {
	float2 p = texel.xy * delta;
	float4 c = SAMPLE_TEXTURE2D(tex, state, uv + float2(-1, -1) * p);
	c += SAMPLE_TEXTURE2D(tex, state, uv + float2(1, -1) * p);
	c += SAMPLE_TEXTURE2D(tex, state, uv + float2(-1, 1) * p);
	c += SAMPLE_TEXTURE2D(tex, state, uv + float2(1, 1) * p);

	return c * 0.25;
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

const static float gaussianWeights[5] = { 0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216 };
float3 SampleGaussian(Texture2D tex, SamplerState state, float2 texel, float2 uv) {
	float3 c = (float3)0;

	c += SAMPLE_TEXTURE2D(tex, state, uv + texel.xy).rgb * gaussianWeights[0];

	for (int i = 1; i < 5; i++) {
		c += SAMPLE_TEXTURE2D(tex, state, uv + i * texel.xy).rgb * gaussianWeights[i];
		c += SAMPLE_TEXTURE2D(tex, state, uv - i * texel.xy).rgb * gaussianWeights[i];
	}
	return c;
}

float Gray(float3 c){
    return dot(float3(0.2,0.7,0.07),c);
}

#endif // POSTLIB_HLSL
