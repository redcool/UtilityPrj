#if !defined(RENDERING_DATA_HLSL)
#define RENDERING_DATA_HLSL

/**
    transformd by script
**/

#define LIGHT_MODE_DISABLED 0
#define LIGHT_MODE_PIXEL 1
#define LIGHT_MODE_VERTEX 2

// CBUFFER_START(UnityPerDraw)
    bool _MainLightShadowOn; // URP Asset mainlight shadow is on?
    bool _MainLightShadowCascadeOn; 
    bool _Shadows_ShadowMaskOn;
    bool _LightmapOn;
    int _MainLightMode; //{0 : disable,1 : pixel, 2 :vertex}
    int _AdditionalLightMode; 

// CBUFFER_END

bool IsAdditionalLightVertex(){
    return _AdditionalLightMode == LIGHT_MODE_VERTEX;
}
bool IsAdditionalLightPixel(){
    return _AdditionalLightMode == LIGHT_MODE_PIXEL;
}

#endif //RENDERING_DATA_HLSL