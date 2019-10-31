// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#ifndef SIMPLE_LIGHTING_CGINC
#define SIMPLE_LIGHTING_CGINC

#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

struct appdata{
    float4 vertex:POSITION;
    float2 uv:TEXCOORD;
    float3 normal:NORMAL;
};

struct v2f{
    float4 vertex:SV_POSITION;
    float2 uv:TEXCOORD;
    float3 normal:TEXCOORD1;
    float3 worldPos:TEXCOORD2;
    #if defined(VERTEXLIGHT_ON)
    float3 sh:COLOR1;
    #endif
};

sampler2D _MainTex;
float4 _MainTex_ST;
float _Metallic;
float _Smoothness;

v2f vert(appdata v){
    v2f o = (v2f)0;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv,_MainTex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld,v.vertex);

    #if defined(VERTEXLIGHT_ON)
    o.sh = Shade4PointLights(
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb,
			unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, o.worldPos, o.normal
		);
    #endif
    return o;
}

UnityLight CreateLight(v2f i){
    UnityLight light;
    light.dir = _WorldSpaceLightPos0.xyz;
    #if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
        light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
    #endif
    UNITY_LIGHT_ATTENUATION(atten,0,i.worldPos);
    light.color = _LightColor0.rgb * atten;
    return light;
}

UnityIndirect CreateIndirectLight(v2f i){
    UnityIndirect light;
    light.diffuse = 0;
    light.specular = 0;
    #if defined(VERTEXLIGHT_ON)
        light.diffuse = i.sh;
    #endif

    light.diffuse += max(0,ShadeSH9(float4(i.normal,1)));
    return light;
};

float4 frag(v2f i):SV_TARGET{
    i.normal = normalize(i.normal);

    float3 viewDir = UnityWorldSpaceViewDir(i.worldPos);

    float3 albedo = tex2D(_MainTex,i.uv).rgb;
    float3 specularTint;
    float oneMinusReflectivity;
    albedo = DiffuseAndSpecularFromMetallic(
        albedo,_Metallic,specularTint,oneMinusReflectivity
    );
    return UNITY_BRDF_PBS(
        albedo,specularTint,
        oneMinusReflectivity,_Smoothness,
        i.normal,viewDir,
        CreateLight(i),CreateIndirectLight(i)
    );
}

#endif //SIMPLE_LIGHTING_CGINC