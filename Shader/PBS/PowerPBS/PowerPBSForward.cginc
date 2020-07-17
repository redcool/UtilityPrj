#if !defined(POWER_PBS_FORWARD_CGINC)
#define POWER_PBS_FORWARD_CGINC
#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "UnityLightingCommon.cginc"
#include "PowerPBSCore.cginc"

struct appdata{
    float4 vertex:POSITION;
    float4 texcoord:TEXCOORD;
    float4 texcoord1:TEXCOORD1;
    float4 texcoord2:TEXCOORD2;
    float4 texcoord3:TEXCOORD3;
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
};

struct v2f
{
    float4 uv : TEXCOORD0;
    UNITY_FOG_COORDS(1)
    float4 pos : SV_POSITION;
    float4 tSpace0:TEXCOORD2;
    float4 tSpace1:TEXCOORD3;
    float4 tSpace2:TEXCOORD4;
    UNITY_SHADOW_COORDS(5)
    float4 shlmap:TEXCOORD6;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _Color;
sampler2D _NormalMap;
float _NormalScale;

sampler2D _MetallicMap;
float _Metallic;

float _Smoothness;

sampler2D _OcclusionMap;
float _Occlusion;

sampler2D _HeightMap;
float _Height;

int _DetailUseUV2;
sampler2D _DetailMaskMap;
sampler2D _DetailAlbedoMap;
sampler2D _DetailNormalMap;
float _DetailNormalScale;

float4 _ClearCoatSpecColor;
float _ClearCoatSmoothness;
sampler2D _ClearCoatNormalMap;
float _ClearCoatNormalScale;

v2f vert (appdata v)
{
    v2f o = (v2f)0;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
    o.uv.zw = v.texcoord2.xy;

    UNITY_TRANSFER_FOG(o,o.vertex);
    float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
    float3 n = UnityObjectToWorldNormal(v.normal);
    float3 t = UnityObjectToWorldDir(v.tangent.xyz);
    float3 b = cross(n,t) * v.tangent.w;
    o.tSpace0 = float4(t.x,b.x,n.x,worldPos.x);
    o.tSpace1 = float4(t.y,b.y,n.y,worldPos.y);
    o.tSpace2 = float4(t.z,b.z,n.z,worldPos.z);

    // UNITY_TRANSFER_LIGHTING(o , v.uv1);
    TRANSFER_SHADOW(o)

    o.shlmap = VertexGI(float4(v.texcoord.xy,v.texcoord1.xy),worldPos,n);

    return o;
}

float3 GetNormal(sampler2D normalMap,float2 uv,float scale){
    float3 n = UnpackScaleNormal(tex2D(normalMap,uv),scale);
    n.z = sqrt(1 - saturate(dot(n.xy,n.xy)));
    //n = float3(dot(tSpace0.xyz,n),dot(tSpace1.xyz,n),dot(tSpace2.xyz,n));
    //n = mul(n,tangentSpace);
    return normalize(n);
}

float3 CalcNormal(float2 uv,float mask){
    float3 n = GetNormal(_NormalMap,uv.xy,_NormalScale);
    #if defined(DETAIL_MAP)
        //detail map
        float3 n2 = GetNormal(_DetailNormalMap,uv.xy,_DetailNormalScale);
        n2 = BlendNormals(n,n2);
        n = lerp(n,n2,mask);
    #endif
    return n;
}

float4 CalcAlbedo(float2 uv,float mask){
    float4 albedo = tex2D(_MainTex, uv) * _Color;
    #if defined(DETAIL_MAP)
        float4 detailAlbedo = tex2D(_DetailAlbedoMap,uv);
        //detailAlbedo.rgb *= 2;
        //albedo = lerp(albedo,detailAlbedo,mask);
            albedo.rgb *= LerpWhiteTo (detailAlbedo * unity_ColorSpaceDouble.rgb, mask);
    #endif
    return albedo;
}

fixed4 frag (v2f i) : SV_Target
{
    float3 worldPos = float3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);
    float3x3 tangentSpace = {i.tSpace0.xyz,i.tSpace1.xyz,i.tSpace2.xyz};
    
    float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
    float3 l = normalize(UnityWorldSpaceLightDir(worldPos));

    UNITY_LIGHT_ATTENUATION(atten,i,worldPos);

    //parallax(height)
    float height = tex2D(_HeightMap,i.uv).b;
    float3 tangentView = normalize(mul(v,tangentSpace));
    float2 offset = ParallaxOffset1Step(height,_Height,tangentView);
    //float2 offset = float2(height*(_Height) * tangentView.xy);
    float2 uv = i.uv.xy + offset;

    //detail mask
    float mask = tex2D(_DetailMaskMap,uv.xy).a;

    //normal map
    float3 n = CalcNormal(uv.xy,mask);
    n = mul(tangentSpace,n);

    //occlusion
    float4 occlusionMap = tex2D(_OcclusionMap,uv);
    float occlusion = occlusionMap.g * _Occlusion;

    //metallic
    float4 metallicMap = tex2D(_MetallicMap,uv);
    float metallic = metallicMap.r * _Metallic;
    float smoothness = metallicMap.a * _Smoothness;

    // calculate gi
    UnityGI gi = CalcGI(l,v,worldPos,n,atten,i.shlmap,smoothness,occlusion);
    // sample the texture
    float4 albedo = CalcAlbedo(uv.xy,mask);

    float3 specColor;
    float oneMinusReflectivity;
    albedo.rgb = DiffuseSpecularFromMetallic(albedo.rgb,metallic,specColor,oneMinusReflectivity);

    float outputAlpha;
    albedo.rgb = PreMultiplyAlpha(albedo.rgb,albedo.a,oneMinusReflectivity,outputAlpha);

    float4 c = PBS(albedo.rgb,specColor,oneMinusReflectivity,_Smoothness,n,v,gi.light,gi.indirect);
    c.a = outputAlpha;

    #if defined(CLEAR_COAT)
        float3 normalClearCoat = GetNormal(_ClearCoatNormalMap,uv,_ClearCoatNormalScale);
        UnityGI giClearCoat = CalcGI(l,v,worldPos,normalClearCoat,atten,i.shlmap,_ClearCoatSmoothness,occlusion);
        float4 colorClearCoat = PBS(0,_ClearCoatSpecColor,oneMinusReflectivity,_ClearCoatSmoothness,n,v,gi.light,giClearCoat.indirect);
        c.rgb += colorClearCoat.rgb;
    #endif
    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, c);
    return c;
}
#endif //end of POWER_PBS_FORWARD_CGINC