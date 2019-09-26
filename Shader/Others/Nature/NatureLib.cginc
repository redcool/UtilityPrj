
#ifndef SNOW_CGINC
#define SNOW_CGINC

#ifdef PLANTS

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
// end PLANTS
#endif

#ifdef SNOW
#define SNOW_V2F(idx) float4 noiseUV:TEXCOORD##idx
#define SNOW_VERTEX(v2f) v2f.noiseUV = v2f.uv.xyxy * _SnowTile;

sampler2D _SnowNoiseMap;
float _NoiseDistortNormalIntensity;

float4 _SnowColor;
float4 _SnowTile;
float _SnowIntensity;

float4 _SnowDirection;
float _SnowAngleIntensity;
float4 _GlobalSnowDirection;
float _GlobalSnowAngleIntensity;

float4 _SnowRimColor;
float _BorderWidth,_BorderWidthScale;
//-------
#ifdef SNOW_DISTANCE
float _Distance;//(高度)
float _DistanceAttenWidth;
#endif

float Gray(float3 c) {
	return dot(float3(0.2, 0.7, 0.07), c);
}

//vertex : compute final position
void SnowDir(float3 vertex, float3 normal, out float3 pos, out float3 worldNormal) {
	float3 worldPos = mul((float3x3)unity_ObjectToWorld, vertex);
	worldNormal = UnityObjectToWorldNormal(normal);

	float3 snowDir = normalize(_SnowDirection.xyz + _GlobalSnowDirection.xyz);
	float snowIntensity = clamp(_SnowDirection.w + _GlobalSnowDirection.w, 0, .2);

	float snowDot = saturate(dot(worldNormal, snowDir)) * snowIntensity;
	float upDot = saturate(dot(worldPos, float3(0, 1, 0)));

	pos = snowDir * snowDot * upDot;
	pos = mul((float3x3)unity_WorldToObject, worldPos + pos);
}

//fragment : final color
float4 SnowColor(float2 uv, float4 mainColor, float3 worldNormal, float3 worldPos, float vertexY) {
	//return mainColor;
	// uv
	float2 noiseUV = worldPos.xz * _SnowTile;

	// normal 
	float4 noise = tex2D(_SnowNoiseMap, noiseUV);
	float3 n = UnpackNormal(noise);
	n = worldNormal + n * _NoiseDistortNormalIntensity;
	n = normalize(n);

	// dot
	float3 snowDir = normalize(_SnowDirection.xyz);
	float snowDot = saturate(dot(n, snowDir));
	//return snowDot;
	//float snowHardRate = step(_SnowAngleIntensity, snowDot); // 硬边界效果
	float snowRate = smoothstep(snowDot, 0.1, _SnowAngleIntensity) * 2 * snowDot;
	// mask
	float border = Gray(mainColor.rgb);
	float borderWidth = lerp(_BorderWidthScale,1,step(_BorderWidthScale,0)) * _BorderWidth;
	float edge = smoothstep(border, border - 0.3, borderWidth); // 混合出缝隙

	// final color
	//float noiseGray = Gray(noise.rgb);
	float4 snowColor = lerp(_SnowColor, mainColor, edge);
	snowColor = lerp(mainColor, snowColor, snowRate);
#ifdef SNOW_DISTANCE
	float yDist = (vertexY - abs(_Distance)) * _DistanceAttenWidth + _DistanceAttenWidth;
	float yRate = lerp(0, 1, saturate(yDist));
	//return yRate ;//lerp(0, 1, yRate);
	//yRate = smoothstep(yRate,0,_DistanceAttenWidth);
	snowColor = lerp(mainColor, snowColor, yRate);
#endif
	return snowColor;
}
// end SNOW
#endif

// end outer
#endif