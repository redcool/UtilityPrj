#if !defined(POWER_SUFRACE_INPUT_DATA_HLSL)
#define POWER_SUFRACE_INPUT_DATA_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

struct SurfaceInputData{
    SurfaceData surfaceData;
    InputData inputData;
    bool isAlphaPremultiply;
    bool isShadowOn;
    float lightmapSH;
    // bool hasShadowCascade;
};

// CBUFFER_START(UnityPerDraw)
    bool _MainLightShadowCascadeOn;  // transformd by script
    bool _LightmapOn;
    bool _Shadows_ShadowMaskOn;
// CBUFFER_END


#endif //POWER_SUFRACE_INPUT_DATA_HLSL