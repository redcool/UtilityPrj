#ifndef FOG_LIB_CGINC
#define FOG_LIB_CGINC

#if defined(FOG_LINEAR)
    #define RETURN_FOG_CLAMP(coord) fixed fog = GetFogFactor(coord); if(fog < _FogFactor) return unity_FogColor;
#endif

float GetFogFactor(float fogCoord){
    float coord = max(((1.0-(fogCoord)/_ProjectionParams.y)*_ProjectionParams.z),0);
    float factor = coord * unity_FogParams.z + unity_FogParams.w;
    return factor;
}

// Fog
float _HeightFogMin;
float _HeightFogMax;
float _HeightFogNear;
float _HeightFogFar;
float4 _sunFogColor;
float4 _HeightFogColor;
float3 _SunFogDir;
bool _FogOn;

float2 GetHeightFog(float3 worldPos){
    float3 viewPos = UnityWorldToViewPos(worldPos.xyzx);
    float hightFogFactor = saturate((viewPos - _HeightFogNear) / (_HeightFogFar - _HeightFogNear));
    float height = 1 - saturate((worldPos.y - _HeightFogMin) / (_HeightFogMax - _HeightFogMin));
    float2 fog = (float2)0;
    fog.x = hightFogFactor * pow(height,4);
    fog.y = height;
    return fog; 
}

void BlendFog(float3 viewDir,float2 fogCoord,inout float3 mainColor){
    // #if defined(FOG_ON)
    if(_FogOn){
        float nl =saturate( dot(-viewDir,normalize(_SunFogDir)));
        float3 sunFogColor  = lerp(_HeightFogColor,_sunFogColor,pow(nl,2));
        unity_FogColor.rgb = lerp(sunFogColor, unity_FogColor.rgb, fogCoord.y * fogCoord.y);
        mainColor = lerp(mainColor ,unity_FogColor.rgb, fogCoord.x);
    }
    // #endif
}

#endif  // FOG_LIB_CGINC