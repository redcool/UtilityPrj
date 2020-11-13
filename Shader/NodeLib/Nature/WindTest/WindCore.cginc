#if !defined(WIND_CORE_CGINC)
#define WIND_CORE_CGINC
/**
	植物风力
*/
// #ifdef PLANTS
#include "TerrainEngine.cginc"
float4 _Wave;
float4 _AttenField;
float3 _WorldPos;
float3 _WorldScale;

float _GlobalWindIntensity;
float3 _GlobalWindDir;
//#define PLANTS_IN_WORLD

float4 ClampVertexWave(appdata_full v, float4 wave, float yDist, float xzDist) {
#if defined(EXPAND_BILLBOARD)
    ExpandBillboard (UNITY_MATRIX_IT_MV, v.vertex, v.normal, v.tangent);
#endif
	//setup _Wind
	_Wind.w += _GlobalWindIntensity; // apply global wind
	_Wind.xyz += _GlobalWindDir;
	//_Wind.xyz = normalize(_Wind.xyz); 	//避免顶点拉伸

	float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
	float4 wavePos = AnimateVertex(worldPos, v.normal, float4(v.color.xy, v.texcoord1.xy)  * wave);

//calcuate atten
	xzDist *= abs(_WorldScale.x);
	yDist *= abs(_WorldScale.y);

	float3 attenField = float3(xzDist,yDist,xzDist);
	float3 worldPosOffset = worldPos - _WorldPos;
	float xzAtten = saturate(length(worldPosOffset.xz) - attenField.x);
	float yAtten = saturate(worldPosOffset.y - attenField.y);

	float atten = saturate(xzAtten + yAtten);
	//atten *= WeatherIntensity();
	float4 vertex = lerp(worldPos,wavePos,atten);
	return mul(unity_WorldToObject, vertex);
}
// #endif // end PLANTS
#endif // WIND_CORE_CGINC