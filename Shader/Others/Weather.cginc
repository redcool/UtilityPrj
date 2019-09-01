#ifndef SNOW_CGINC
#define SNOW_CGINC


#include "UnityBuiltin3xTreeLibrary.cginc"

inline float4 ClampWave(appdata_full v, float4 wave, float yRadius, float xzRadius) {
	float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

	float xzAtten = saturate(length(v.vertex.xz) - xzRadius);
	float yAtten = saturate(v.vertex.y - yRadius);
	float atten = xzAtten * yAtten;

	float4 wavePos = AnimateVertex(worldPos, v.normal, float4(v.color.xy, v.texcoord.xy)  * wave);

	float4 vertex = lerp(worldPos, wavePos, atten);
	return mul(unity_WorldToObject, vertex);
}


float3 SnowDir(float3 vertex, float3 normal, float3 snowDir, float snowIntensity) {
	normal = normalize(normal);
	snowDir = normalize(snowDir);
	snowIntensity = clamp(snowIntensity, 0, .2);

	float snowDot = saturate(dot(normal, snowDir)) * snowIntensity;
	float upDot = saturate(dot(vertex, float3(0, 1, 0)));
	return  snowDir * snowDot * upDot;
}
float4 SnowColor(float4 mainColor, float4 snowColor, float3 normal, float3 snowDir, float snowPower) {
	normal = normalize(normal);
	snowDir = normalize(snowDir);
	snowPower = max(snowPower, 0.01);

	float snowDot = saturate(dot(normal, snowDir));
	snowDot = saturate(pow(snowDot, snowPower));

	return lerp(mainColor, snowColor, snowDot);
}
#endif