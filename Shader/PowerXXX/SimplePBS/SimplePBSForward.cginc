#if !defined(SIMPLE_PBS_FORWARD_CGINC)
#define SIMPLE_PBS_FORWARD_CGINC

#include "UnityCG.cginc"
#include "UnityStandardutils.cginc"
// #include "UnityPBSLighting.cginc"
#include "UnityStandardBRDF.cginc"
#include "SimplePBSCore.cginc"

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
    float3 viewTangentSpace:TEXCOORD5;
};

//-------------------------------------
v2f vert (appdata v)
{
    v2f o = (v2f)0;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);

    float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
    float3 n = UnityObjectToWorldNormal(v.normal);
    float3 t = UnityObjectToWorldDir(v.tangent.xyz);
    float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
    float3 b = cross(n,t) * tangentSign;
    o.tSpace0 = float4(t.x,b.x,n.x,worldPos.x);
    o.tSpace1 = float4(t.y,b.y,n.y,worldPos.y);
    o.tSpace2 = float4(t.z,b.z,n.z,worldPos.z);

    if(_ParallalOn){
        float3 viewWorldSpace = UnityWorldSpaceViewDir(worldPos);
        float3x3 tSpace = float3x3(o.tSpace0.xyz,o.tSpace1.xyz,o.tSpace2.xyz);
        o.viewTangentSpace = mul(viewWorldSpace,tSpace);
    }

    UNITY_TRANSFER_FOG(o,o.vertex);
    return o;
}

float4 frag (v2f i) : SV_Target
{
    float2 uv = Parallax(i.uv,i.viewTangentSpace);
    float3 worldPos = float3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);

    //detail mask
    float detailMask = 0;
    if(_DetailMapOn){
        detailMask = tex2D(_DetailMapMask,uv).b;
        // return detailMask;
    }

    float3 tn = CalcNormal(uv,detailMask);
    float3 n = normalize(float3(
        dot(i.tSpace0.xyz,tn),
        dot(i.tSpace1.xyz,tn),
        dot(i.tSpace2.xyz,tn)
    ));
    float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
    float3 r = reflect(-v,n);


    float metallic = tex2D(_MetallicMap,uv).r * _Metallic;
    float smoothness = tex2D(_SmoothnessMap,uv).g * _Smoothness;
    float roughness = 1.0 - smoothness;
    // roughness = roughness * roughness;

    float occlusion = tex2D(_OcclusionMap,uv).b * _Occlusion;

    float4 mainTex = CalcAlbedo(uv,detailMask * _DetailMapIntensity);
    float3 albedo = mainTex.rgb;
    albedo.rgb *= occlusion;
    float alpha = mainTex.a;


    if(_AlphaTestOn)
        clip(alpha - 0.5);

    UnityLight light = GetLight();
    // UnityLight light = {_LightColor0.xyz,_WorldSpaceLightPos0.xyz,0};

    UnityIndirect indirect = CalcGI(albedo,uv,r,n,occlusion,roughness);    

    half oneMinusReflectivity;
    half3 specColor;
    albedo = DiffuseAndSpecularFromMetallic (albedo, metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);
// specColor *= albedo;

    half outputAlpha;
    albedo = AlphaPreMultiply (albedo, alpha, oneMinusReflectivity, /*out*/ outputAlpha);

    // half4 c = UNITY_BRDF_PBS (albedo, specColor, oneMinusReflectivity, smoothness, n, v, light, indirect);
    PBSData data = (PBSData)0;
    data.tangent = float3(i.tSpace0.x,i.tSpace1.x,i.tSpace2.x);
    data.bitangent = float3(i.tSpace0.y,i.tSpace1.y,i.tSpace2.y);
    data.clothMask = 1;

    if(_ClothMaskOn){
        data.clothMask = tex2D(_ClothMaskMap,uv).r;
    }

    half4 c = CalcPBS(albedo, specColor, oneMinusReflectivity, smoothness, n, v, light, indirect,data);
    c.a = outputAlpha;

    c.rgb += albedo * tex2D(_EmissionMap,uv).rgb * _Emission;
    if(_SSSOn){
        c.rgb += CalcSSS(uv,light.dir,v);
    }
    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, c);
    return c;
}

#endif // SIMPLE_PBS_FORWARD_CGINC