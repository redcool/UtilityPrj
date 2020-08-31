// Upgrade NOTE: replaced 'defined SIMPLE_PBS_CORE_CGINC' with 'defined (SIMPLE_PBS_CORE_CGINC)'

#if !defined (SIMPLE_PBS_CORE_CGINC)
#define SIMPLE_PBS_CORE_CGINC

#include "UnityCG.cginc"
#include "UnityStandardutils.cginc"
#include "UnityPBSLighting.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    UNITY_FOG_COORDS(1)
    float4 vertex : SV_POSITION;
    float4 tSpace0:TEXCOORD2;
    float4 tSpace1:TEXCOORD3;
    float4 tSpace2:TEXCOORD4;
};

sampler2D _MainTex;
float4 _Color;
float4 _MainTex_ST;
sampler2D _NormalMap;
float _NormalMapScale;

sampler2D _SmoothnessMap;
float _Smoothness;

sampler2D _MetallicMap;
float _Metallic;
sampler2D _OcclusionMap;
float _Occlusion;

samplerCUBE _EnvCube;
float _EnvIntensity;

sampler2D _EmissionMap;
float _Emission;
float _IndirectIntensity;

int _AlphaTestOn;

// -------------------------------------- main light
#define MAX_SPECULAR 25
//---- 当前物体的光照
int _CustomLightOn;
fixed4 _LightDir;
fixed4 _LightColor;

float3 _MainLightDir;
float3 _MainLightColor;

UnityLight GetLight(){
    float3 dir = _MainLightDir;
    float3 color = _MainLightColor;

    // ---- 改变主光源,方向,颜色.
    dir.xyz += _CustomLightOn > 0 ? _LightDir.xyz : 0;
    color += _CustomLightOn > 0 ?_LightColor : 0;
    dir = normalize(dir);

    UnityLight l = {color.rgb,dir.xyz,0};
    return l;
}

//-------------------------------------
v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);

    float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
    float3 n = UnityObjectToWorldNormal(v.normal);
    float3 t = UnityObjectToWorldDir(v.tangent.xyz);
    fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
    float3 b = cross(n,t) * tangentSign;
    o.tSpace0 = float4(t.x,b.x,n.x,worldPos.x);
    o.tSpace1 = float4(t.y,b.y,n.y,worldPos.y);
    o.tSpace2 = float4(t.z,b.z,n.z,worldPos.z);

    UNITY_TRANSFER_FOG(o,o.vertex);
    return o;
}

fixed4 frag (v2f i) : SV_Target
{
    float3 worldPos = float3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);

    float3 tn = UnpackScaleNormal(tex2D(_NormalMap,i.uv),_NormalMapScale);
    
    float3 n = normalize(float3(
        dot(i.tSpace0.xyz,tn),
        dot(i.tSpace1.xyz,tn),
        dot(i.tSpace2.xyz,tn)
    ));

    float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
    float3 r = reflect(-v,n);

    float metallic = tex2D(_MetallicMap,i.uv).r * _Metallic;
    float smoothness = tex2D(_SmoothnessMap,i.uv).g * _Smoothness;
    float roughness = 1.0 - smoothness;
    // roughness = roughness * roughness;

    float occlusion = tex2D(_OcclusionMap,i.uv).b * _Occlusion;

    float4 mainTex = tex2D(_MainTex, i.uv) * _Color;
    float3 albedo = mainTex.rgb * occlusion;
    float alpha = mainTex.a;

    if(_AlphaTestOn)
        clip(alpha - 0.5);

    float3 indirectSpecular = texCUBElod(_EnvCube,float4(i.uv,0,roughness*6)) * occlusion * _EnvIntensity;
    float3 indrectDiffuse = albedo * _IndirectIntensity * occlusion;

    UnityLight light = GetLight();
    // UnityLight light = {_LightColor0.xyz,_WorldSpaceLightPos0.xyz,0};
    
    UnityIndirect indirect = {indrectDiffuse,indirectSpecular};

    half oneMinusReflectivity;
    half3 specColor;
    albedo = DiffuseAndSpecularFromMetallic (albedo, metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    half outputAlpha;
    albedo = PreMultiplyAlpha (albedo, alpha, oneMinusReflectivity, /*out*/ outputAlpha);

    half4 c = UNITY_BRDF_PBS (albedo, specColor, oneMinusReflectivity, smoothness, n, v, light, indirect);
    c.a = outputAlpha;

    c.rgb += albedo * tex2D(_EmissionMap,i.uv).rgb * _Emission;
    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, c);
    return c;
}

#endif // end of SIMPLE_PBS_CORE_CGINC