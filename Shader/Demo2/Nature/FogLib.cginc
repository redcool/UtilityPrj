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


#endif  // FOG_LIB_CGINC