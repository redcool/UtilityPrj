#if !defined(RIPPLE_HLSL)
#define RIPPLE_HLSL
#define PI 3.1415926

void ComputeRipple_half(Texture2D<float4> rippleTex,SamplerState state,float2 uv, float t,out float3 result)
{
	float4 ripple = rippleTex.Sample(state,uv);
	ripple.yz = ripple.yz * 2.0 - 1.0;

	float drop = frac(ripple.a + t);
	float move = ripple.x + drop -1.0;
	float dropFactor = 1 - saturate(drop);

	float final = dropFactor * sin(clamp(move*9,0,4)*PI);
	result = float3(ripple.yz * final,1);
}
#endif //RIPPLE_HLSL