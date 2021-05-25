#if !defined(LIGHTING_CGINC)
#define LIGHTING_CGINC

#include "AutoLight.cginc"
#define MAX_LIGHT_COUNT 4


float3 IncomingLight (Surface surface, Light light) {
	return saturate(dot(surface.normal, light.direction)) * light.color;
}

float3 GetLighting (Surface surface, BRDF brdf, Light light) {
	return IncomingLight(surface, light) * DirectBRDF(surface, brdf, light);
}

float3 GetLighting (Surface surface, BRDF brdf) {
	float3 color = 0.0;
    Light l = {_WorldSpaceLightPos0.xyz,_LightColor0.rgb};
color += GetLighting(surface, brdf, l) ;

    // float3 lightDirs[4] = {
    //     float3(unity_4LightPosX0.x,unity_4LightPosY0.x,unity_4LightPosZ0.x),
    //     float3(unity_4LightPosX0.y,unity_4LightPosY0.y,unity_4LightPosZ0.y),
    //     float3(unity_4LightPosX0.z,unity_4LightPosY0.z,unity_4LightPosZ0.z),
    //     float3(unity_4LightPosX0.w,unity_4LightPosY0.w,unity_4LightPosZ0.w)
    // };

    // for(int i=0;i<MAX_LIGHT_COUNT;i++){
	//     Light l = {lightDirs[i],unity_LightColor[i].rgb};
    //      color += GetLighting(surface, brdf, l);
    // }
	return color;
}

#endif//LIGHTING)CGINC