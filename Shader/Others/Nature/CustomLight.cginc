#ifndef CUSTOM_LIGHT_CGINC
#define CUSTOM_LIGHT_CGINC

fixed4 _LightDir;
fixed4 _LightColor;

inline fixed4 LambertLight (SurfaceOutput s, UnityLight light)
{
    fixed diff = max (0, dot (s.Normal, light.dir));

    fixed4 c;
    c.rgb = s.Albedo * light.color * diff;
    c.a = s.Alpha;
    return c;
}

inline fixed4 LightingSimpleLambert (SurfaceOutput s, UnityGI gi)
{
    #if defined(LIGHTMAP_ON)
        _LightDir = length(_LightDir)==0?half4(0,1,0,0):_LightDir;
        
        gi.light.dir += normalize(_LightDir.xyz);
        gi.light.color += _LightColor;
    #endif

    fixed4 c;
    c = LambertLight (s, gi.light);

    #ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
        c.rgb += s.Albedo * gi.indirect.diffuse;
    #endif

    return c;
}

inline void LightingSimpleLambert_GI (
    SurfaceOutput s,
    UnityGIInput data,
    inout UnityGI gi)
{
    gi = UnityGlobalIllumination (data, 1.0, s.Normal);
}
 

#endif // CUSTOM_LIGHT_CGINC