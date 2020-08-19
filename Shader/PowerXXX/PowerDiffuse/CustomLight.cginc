#ifndef CUSTOM_LIGHT_CGINC
#define CUSTOM_LIGHT_CGINC
#include "Lighting.cginc"
#include "GlobalControl.cginc"

#define MAX_SPECULAR 25
//---- 当前物体的光照
int _CustomLightOn;
fixed4 _LightDir;
fixed4 _LightColor;

// ---- 场景光照,替代_WorldSpaceLightPos0,通过代码来传递数据
float3 _MainLightDir;
float3 _MainLightColor;
float _MainLightShadowIntensity;
float4 _AmbientColor;
float _ShadowEdge;
float _ShadowStrength;
float _LightingType;  //[sh,bakedColor]

UnityLight GetLight(){
    float3 dir = _WorldSpaceLightPos0;
    float3 color = _LightColor0;

    #if defined(LIGHTMAP_ON)
        dir = _MainLightDir;
        color = _MainLightColor;
    #endif

    // ---- 改变主光源,方向,颜色.
    dir.xyz += _CustomLightOn > 0 ? _LightDir.xyz : 0;
    color += _CustomLightOn > 0 ?_LightColor : 0;
    dir = normalize(dir);

    UnityLight l = {color.rgb,dir.xyz,0};
    return l;
}

inline fixed4 LambertLight (SurfaceOutput s, UnityLight light)
{
    fixed diff = max (0,dot (s.Normal, light.dir));

    fixed4 c;
    c.rgb = s.Albedo * light.color * diff;
    c.a = s.Alpha;
    return c;
}

inline fixed4 LightingSimpleLambert (SurfaceOutput s, UnityGI gi)
{
    fixed4 c=(float4)0;
    c = LambertLight (s, gi.light);
    #ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
        c.rgb += s.Albedo * gi.indirect.diffuse;
    #endif

    return c;
}

float4 LightingBlinn(SurfaceOutput s,float3 halfDir,UnityGI gi,float shadowAtten,float3 specColor){
    fixed kd = max(0.6,1 - Luminance(specColor));
    // fixed ks = 1 - kd;

    fixed diff = saturate(dot (s.Normal, gi.light.dir));
    fixed4 c=(float4)0;
    c.rgb = s.Albedo * gi.light.color * diff * saturate(shadowAtten + _ShadowStrength) * kd;
    c.a = s.Alpha;

    #ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
        float g = min(0.5,Luminance(gi.indirect.diffuse));
        // float shadow = smoothstep(0.4,0.5,g);
        // return g;
        float diffPart = lerp(1,diff,g);
        // return diffPart;
        c.rgb += s.Albedo * gi.indirect.diffuse * diffPart;
    #endif

    float nh = saturate(dot(normalize(s.Normal),halfDir));
    float3 specular = min(MAX_SPECULAR,pow(nh,s.Specular * 128)) * s.Gloss  * specColor * shadowAtten;
    c.rgb += specular;
    return c;
}

UnityGIInput SetupGIInput(UnityLight light,float3 worldPos,float atten,float4 lmap,float3 sh,out UnityGI gi){
        // Setup lighting environment
    // UnityGI gi;
    UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
    gi.indirect.diffuse = 0;
    gi.indirect.specular = 0;
    gi.light.color = light.color;
    
    gi.light.dir = light.dir;
    // Call GI (lightmaps/SH/reflections) lighting function
    UnityGIInput giInput;
    UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
    giInput.light = gi.light;
    giInput.worldPos = worldPos;
    giInput.atten = atten;
    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    giInput.lightmapUV = lmap;
    #else
        giInput.lightmapUV = 0.0;
        #if UNITY_SHOULD_SAMPLE_SH
            giInput.ambient = sh;
        #else
            giInput.ambient.rgb = 0.0;
        #endif
    #endif
    giInput.probeHDR[0] = unity_SpecCube0_HDR;
    giInput.probeHDR[1] = unity_SpecCube1_HDR;
    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
    giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
    #endif
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
    #endif
    return giInput;
}

float MainLightShadowFromLightmap(float3 bakedColor){
    float g = Luminance(bakedColor);

    float hardShadow = step(_MainLightShadowIntensity,g);
    float softShadow = smoothstep(g*2,g,_MainLightShadowIntensity) ;
    // return softShadow;
    return saturate(lerp(hardShadow,softShadow,_ShadowEdge));
}

float3 ApplyAmbient(float3 c){
    return c + _AmbientColor + 0.2;
}
//使用sh,去除环境色,使用 _AmbientColor.
float3 ApplyAmbientMinusUnityAmbient(float3 c){
    c = c - UNITY_LIGHTMODEL_AMBIENT;
    return ApplyAmbient(c);
}
 
inline void CalcGI (
    SurfaceOutput s,
    UnityGIInput data,
    float3 bakedColor,
    inout UnityGI o_gi,
    inout float atten)
{
    // o_gi = UnityGI_Base(data,1,s.Normal);
    // return;
    
    float3 normalWorld = s.Normal;
    o_gi = (UnityGI)0;

    o_gi.light = data.light;
    o_gi.light.color *= data.atten;
    
    // o_gi.indirect.diffuse = ShadeSH9(float4(normalWorld,1));//ApplyAmbient(ShadeSHPerPixel(normalWorld, data.ambient, data.worldPos));
    // return;

    #if UNITY_SHOULD_SAMPLE_SH
        o_gi.indirect.diffuse = ShadeSHPerPixel(normalWorld, data.ambient, data.worldPos);
    #endif
    #if defined(LIGHTMAP_ON)
        // Baked lightmaps
        // half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, data.lightmapUV.xy);
        // bakedColor = DecodeLightmap(bakedColorTex);
        // // -------- test 
        // o_gi.indirect.diffuse += ApplyAmbient(bakedColor);
        // return;

        // get shadow from lightmap
        atten = MainLightShadowFromLightmap(bakedColor);
        
        //use sh + lightmap shadow
        float3 sh = ApplyAmbientMinusUnityAmbient(ShadeSHPerPixel(normalWorld, data.ambient, data.worldPos));
        bakedColor = ApplyAmbient(bakedColor);

        float nl = saturate(dot(normalWorld,data.light.dir));
        float3 diffuse = lerp(sh,bakedColor, _LightingType);
        o_gi.indirect.diffuse += diffuse ;

        #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
            ResetUnityLight(o_gi.light);
            o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap(o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
        #endif
    #endif
    
}

inline void CalcGI (
    SurfaceOutput s,
    UnityGIInput data,
    inout UnityGI o_gi,
    inout float atten)
{
    float3 bakedColor = (float3)0;
    #if defined(LIGHTMAP_ON)
        bakedColor = BlendNightLightmap(data.lightmapUV.xy);
    #endif
    CalcGI(s,data,bakedColor,/**/o_gi,/**/atten);
}
#endif // CUSTOM_LIGHT_CGINC