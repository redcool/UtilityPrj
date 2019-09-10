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
#define SNOW_V2F(idx) float4 normalUV:TEXCOORD##idx
#define SNOW_VERTEX(v2f) v2f.normalUV = v2f.uv.xyxy * _SnowTile;

sampler2D _SnowNoiseMap;
float _SnowNoiseIntensity;

float4 _SnowColor;
float4 _SnowTile;
float _SnowIntensity;

float4 _SnowDirection;
float _SnowAmount;
float4 _GlobalSnowDirection;
float _GlobalSnowAmount;

float4 _SnowRimColor;
float _SnowRimPower;

float4 SnowRimColor(float3 worldNormal, float3 worldPos) {
	float3 v = UnityWorldSpaceViewDir(worldPos);
	float3 l = UnityWorldSpaceLightDir(worldPos);
	float3 h = normalize(l + v);

	float nv = saturate(dot(worldNormal, h));
	float rim = pow(1 - nv, _SnowRimPower);
	return _SnowRimColor * rim;
}

//vertex : compute final position
void SnowDir(float3 vertex, float3 normal,out float3 pos, out float3 worldNormal) {
	float3 worldPos = mul(unity_ObjectToWorld,vertex);
	worldNormal = UnityObjectToWorldNormal(normal);

	float3 snowDir = normalize(_SnowDirection.xyz + _GlobalSnowDirection.xyz);
	float snowIntensity = clamp(_SnowDirection.w + _GlobalSnowDirection.w, 0, .2);

	float snowDot = saturate(dot(worldNormal, snowDir)) * snowIntensity;
	float upDot = saturate(dot(worldPos, float3(0, 1, 0)));

	pos = snowDir * snowDot * upDot;
	pos = mul(unity_WorldToObject,worldPos + pos);
}

//fragment : final color
float4 SnowColor(sampler2D noiseMap,float4 normalUV,float4 mainColor,float3 worldNormal,float3 worldPos) {
	// normal 
	normalUV *= _SnowTile;

	// rim
	float4 snowRimColor = SnowRimColor(worldNormal, worldPos);

	// noise 
	float3 noise = tex2D(noiseMap, normalUV.xy) ;
	float gray = dot(float3(0.2, 0.7, 0.07), noise) * _SnowNoiseIntensity;

	// 
	float snowRate = max(_SnowAmount + _GlobalSnowAmount, 0.01);
	float3 snowDir = normalize(_SnowDirection.xyz + _GlobalSnowDirection.xyz);
	float snowDot = saturate(dot(worldNormal, snowDir));
	//return _SnowColor * snowDot;

	// final color
	float4 snowColor = _SnowColor - gray;
	float4 lerpColor = lerp(mainColor, snowColor, step(_SnowAmount,snowDot));
	return lerp(mainColor,lerpColor,step(snowDot,_SnowIntensity));
}


// end SNOW
#endif

// end outer
#endif