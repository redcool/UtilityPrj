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
    outNormalUV = uv.xyxy * _Tile + _Time.xxxx* _Direction;

#define WATER_FRAG_FUNCTION_INSTANCE(mainColor,normalUV,normal,uv,worldPos,mainTex,mainTint)\
	float3 noiseNormal;\
	float2 noiseUV;\
	float edge;\
	NoiseUVNormal(mainColor,normalUV,normal,noiseUV,noiseNormal,edge);\
	float4 noiseCol = tex2D(mainTex,uv + noiseUV) * mainTint;\
	v2f_surface v2fSurface = {uv,worldPos.xyz,normal};\
	half4 surfaceColor = SurfaceWaveFrag(v2fSurface,noiseCol,noiseNormal,edge);\
	mainColor.rgb = surfaceColor.rgb;

#define WATER_FRAG_FUNCTION(mainColor,normalUV,normal,uv,worldPos)\
	float3 noiseNormal;\
	float2 noiseUV;\
	float edge;\
	NoiseUVNormal(mainColor,normalUV,normal,noiseUV,noiseNormal,edge);\
	float4 noiseCol = tex2D(_MainTex,uv + noiseUV) * _Color;\
	v2f_surface v2fSurface = {uv,worldPos.xyz,normal};\
	half4 surfaceColor = SurfaceWaveFrag(v2fSurface,noiseCol,noiseNormal,edge);\
	mainColor.rgb = surfaceColor.rgb;
//使用涟漪效果(WMSJ_zulongcheng_sea2.shader用)
#define WATER_RIPPLE_FUNCTION(mainColor,uv,worldPos,normal)\
	float3 noiseNormal=float3(0,1,0);\
	float2 noiseUV=(float2)0;\
	float edge=(float)0;\
	half4 noiseCol=(half4)0;\
	v2f_surface v2fSurface = {uv,worldPos.xyz,normal};\
	half4 surfaceColor = SurfaceWaveFrag(v2fSurface,mainColor,noiseNormal,edge);\
	mainColor.rgb = surfaceColor.rgb;

//通用流水,根据条件,使用平面流水或涟漪.
#define WATER_FRAG_TERRAIN(mainColor,normalUV,worldPos,worldNormal,mainUV,controlMap,uv_Splat0,uv_Splat1,uv_Splat2,uv_Splat3, _Splat0,_Splat1,_Splat2,_Splat3)\
    float3 noiseNormal;\
    float2 noiseUV;\
    float edge;\
	float3 envColor=(float3)0;\
    NoiseUVNormal(mainColor,normalUV,worldNormal,noiseUV,noiseNormal,edge);\
    float4 noiseCol = SampleSplatsInRain(controlMap,uv_Splat0 + noiseUV,uv_Splat1 + noiseUV,uv_Splat2 + noiseUV,uv_Splat3 + noiseUV,_Splat0,_Splat1,_Splat2,_Splat3,mainColor);\
    v2f_surface v2fSurface = {mainUV,worldPos,worldNormal};\
    mainColor.rgb = SurfaceWaveFrag(v2fSurface,noiseCol,noiseNormal,edge,envColor);
#endif//_FEATURE_SURFACE_WAVE

	// #define UNITY_INSTANCING_BUFFER_START(Props) UNITY_INSTANCING_CBUFFER_START(Props)
	// #define UNITY_INSTANCING_BUFFER_END(Props) UNITY_INSTANCING_CBUFFER_END
	// #define ACCESS_INSTANCED_PROP(arr,var) UNITY_ACCESS_INSTANCED_PROP(var)
#endif //NATURE_LIB_MACRO_CGINC