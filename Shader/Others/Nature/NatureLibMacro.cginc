#if !defined(NATURE_LIB_MACRO_CGINC)
#define NATURE_LIB_MACRO_CGINC

// include 
#include "NatureLib.cginc"

//function macros
#if defined(_FEATURE_SNOW)
#define SNOW_VERT_FUNCTION(vertex,normal,outNormal)\
    float3 worldNormal;\
	float3 pos;\
	SnowDir(vertex, normal, pos, worldNormal);\
	vertex.xyz = pos;\
	outNormal = worldNormal;

#define SNOW_FRAG_FUNCTION(uv,mainColor,worldNormal,worldPos)\
    half4 snowColor = SnowColor(uv,mainColor, worldNormal,worldPos.xyz,0);\
	mainColor.rgb = snowColor.rgb;

#endif//_FEATURE_SNOW

#if defined(_FEATURE_SURFACE_WAVE)
#define WATER_VERT_FUNCTION(uv,outNormalUV)\
	SurfaceWaveVertex(uv,outNormalUV)

#define WATER_FRAG_FUNCTION(mainColor,normalUV,normal,uv,worldPos)\
	float3 noiseNormal;\
	float2 noiseUV;\
	float edge;\
	NoiseUVNormal(mainColor,normalUV,normal,noiseUV,noiseNormal,edge);\
	float4 noiseCol = SampleTexInRain(_MainTex,uv+noiseUV,mainColor) * _Color;\
	v2f_surface v2fSurface = {uv,worldPos.xyz,normal};\
	half4 surfaceColor = SurfaceWaveFrag(v2fSurface,noiseCol,noiseNormal,edge);\
	mainColor.rgb = surfaceColor.rgb;

//通用流水,根据条件,使用平面流水或涟漪.
#define WATER_FRAG_TERRAIN(mainColor,normalUV,worldPos,worldNormal,mainUV,controlMap,uv_Splat0,uv_Splat1,uv_Splat2,uv_Splat3, splat0,splat1,splat2,splat3)\
    float3 noiseNormal;\
    float2 noiseUV;\
    float edge;\
	float3 envColor=(float3)0;\
    NoiseUVNormal(mainColor,normalUV,worldNormal,noiseUV,noiseNormal,edge);\
    float4 noiseCol = SampleSplats(controlMap,uv_Splat0 + noiseUV,uv_Splat1 + noiseUV,uv_Splat2 + noiseUV,uv_Splat3 + noiseUV,splat0,splat1,splat2,splat3);\
    v2f_surface v2fSurface = {mainUV,worldPos,worldNormal};\
    mainColor.rgb = SurfaceWaveFrag(v2fSurface,noiseCol,noiseNormal,edge,envColor);
#endif//_FEATURE_SURFACE_WAVE

#endif //NATURE_LIB_MACRO_CGINC