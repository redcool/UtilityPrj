#if !defined(NOISE_MOTION_CGINC)
#define NOISE_MOTION_CGINC

#include "NodeLib.cginc"

float4 Wave(float4 vertex,float3 vertexColor,float2 vertexUV,float speed,float scale,float3 axis){
    half4 worldPos = mul(unity_ObjectToWorld,vertex);

    half2 uv = worldPos.xy + _Time.x * speed;
    half noise = 0;
    Unity_GradientNoise_float(uv,scale, noise);
    
    worldPos.xyz += noise * axis.xyz * vertexColor * vertexUV.y;
    // noise *= _Intensity ;

    return mul(unity_WorldToObject,worldPos);
}

#endif