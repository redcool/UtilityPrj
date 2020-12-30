#ifndef FOG_LIB_CGINC
#define FOG_LIB_CGINC

// #if defined(FOG_LINEAR)
//     #define RETURN_FOG_CLAMP(coord) float fog = GetFogFactor(coord); if(fog < _FogFactor) return unity_FogColor;
// #endif
// inline float GetFogFactor(float fogCoord){
//     float coord = max(((1.0-(fogCoord)/_ProjectionParams.y)*_ProjectionParams.z),0);
//     float factor = coord * unity_FogParams.z + unity_FogParams.w;
//     return factor;
// }

#define FOG_COORDS(id) float2 fog:TEXCOORD##id;

#define FOG_ON (_FogOn && ! _DisableFog)


// Fog
float _HeightFogMin;
float _HeightFogMax;
float _HeightFogNear;
float _HeightFogFar;
float4 _sunFogColor;
float4 _HeightFogColor;
float4 _HeightFogMinColor;
float4 _FogNearColor;
float3 _SunFogDir;
bool _FogOn; //全局的fog
bool _DisableFog; //材质的fog
bool _HeightFogOn;  //全局,HeightFogSetting来控制
bool _PixelFogOn; //frag计算雾系数

inline float CalcFogFactor(float coord){
    // float fogFactor =  max(((1.0-(coord)/_ProjectionParams.y)*_ProjectionParams.z),0);
    float fogFactor = coord * unity_FogParams.z + unity_FogParams.w;
    return fogFactor;
}

 inline float2 GetHeightFog(float3 worldPos){
    if(!FOG_ON)
        return 0;
    
    float2 fog = (float2)0;
    float height = saturate((worldPos.y - _HeightFogMin) / (_HeightFogMax - _HeightFogMin));
    // fog.x = hightFogFactor * pow(height,4);
    float dist = distance(worldPos,_WorldSpaceCameraPos);
    float depth = CalcFogFactor(dist);
    fog.x = saturate(smoothstep(0.25,1,depth) + lerp(0.,0.3,height));
    // saturate(height + fog.x);
    fog.y = saturate(smoothstep(0.9,1,depth) + height);
    return fog; 
}

inline void BlendFog(float3 viewDir,float2 fogCoord,inout float3 mainColor){
    if(!FOG_ON)
        return;
    
    // #if defined(FOG_ON)
    if(_HeightFogOn){
        float3 heightFogColor = lerp(_HeightFogMinColor,_HeightFogColor,fogCoord.y);
        mainColor.rgb = lerp(heightFogColor,mainColor.rgb,fogCoord.y);
    }
    float3 fogColor = lerp(unity_FogColor.rgb,_FogNearColor.rgb,fogCoord.x);
    mainColor = lerp(fogColor,mainColor, fogCoord.x);
    // #endif
}

#endif  // FOG_LIB_CGINC