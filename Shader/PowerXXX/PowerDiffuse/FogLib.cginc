#ifndef FOG_LIB_CGINC
#define FOG_LIB_CGINC

#if defined(FOG_LINEAR)
    #define RETURN_FOG_CLAMP(coord) float fog = GetFogFactor(coord); if(fog < _FogFactor) return unity_FogColor;
#endif

#define FOG_ON (_FogOn && ! _DisableFog)
#define UNITY_FOG 0
#define SPHERE_FOG 1


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

int _FogMode; // fog类型(0 : Unity,1 : SphereFog)

inline bool IsSphereFog(){
    return _FogMode == SPHERE_FOG;
}

inline float2 GetHeightFog(float3 worldPos){
    float3 viewPos = UnityWorldToViewPos(worldPos.xyzx);
    float hightFogFactor = saturate((viewPos - _HeightFogNear) / (_HeightFogFar - _HeightFogNear));
    float height = 1 - saturate((worldPos.y - _HeightFogMin) / (_HeightFogMax - _HeightFogMin));
    float2 fog = (float2)0;
    fog.x = hightFogFactor * pow(height,4);
    fog.y = height;
    return fog; 
}

inline void BlendFog(float3 viewDir,float2 fogCoord,inout float3 mainColor){
    // #if defined(FOG_ON)
    if(_HeightFogOn){
        float nl =saturate( dot(-viewDir,normalize(_SunFogDir)));
        float3 sunFogColor  = lerp(_HeightFogColor,_sunFogColor,pow(nl,2));
        unity_FogColor.rgb = lerp(sunFogColor, unity_FogColor.rgb, fogCoord.y * fogCoord.y);
        mainColor = lerp(mainColor ,unity_FogColor.rgb, fogCoord.x);
    }
    // #endif
}


//----------------------------Sphere Fog
inline float CalcFogFactor(float coord){
    // float fogFactor =  max(((1.0-(coord)/_ProjectionParams.y)*_ProjectionParams.z),0);
    float fogFactor = coord * unity_FogParams.z + unity_FogParams.w;
    return fogFactor;
}

 inline float2 GetHeightFogSphere(float3 worldPos){
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

inline void BlendFogSphere(float3 viewDir,float2 fogCoord,inout float3 mainColor){
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

void BlendFinalFog(float2 fog,float unityFogCoord,float3 viewDir,float3 worldPos,inout float4 mainColor){
    if(IsSphereFog()){
        if(_PixelFogOn){
            fog = GetHeightFogSphere(worldPos);
        }
        BlendFogSphere(viewDir,fog,/*inout*/mainColor.rgb);
    }else{
        BlendFog(viewDir,fog,/*inout*/mainColor.rgb);
        if(_FogOn){
            UNITY_APPLY_FOG(unityFogCoord, mainColor); // apply fog
        }
    }
}

#endif  // FOG_LIB_CGINC