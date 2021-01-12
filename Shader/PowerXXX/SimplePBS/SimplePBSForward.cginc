#if !defined(SIMPLE_PBS_FORWARD_CGINC)
#define SIMPLE_PBS_FORWARD_CGINC

#include "UnityCG.cginc"
#include "UnityStandardutils.cginc"
// #include "UnityPBSLighting.cginc"
#include "UnityStandardBRDF.cginc"
#include "SimplePBSCore.cginc"
#include "SimplePBSHair.cginc"

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
    // heightClothSSSMask
    float4 heightClothSSSMask = tex2D(_HeightClothSSSMask,i.uv);
    float height = heightClothSSSMask.r;
    float clothMask = heightClothSSSMask.g;
    float frontSSS = heightClothSSSMask.b;
    float backSSS = heightClothSSSMask.a;

    float2 uv = Parallax(i.uv,height,i.viewTangentSpace);

    // metallicSmoothnessOcclusion
    float4 metallicSmoothnessOcclusion = tex2D(_MetallicSmoothnessOcclusion ,uv);
    float metallic = metallicSmoothnessOcclusion.r * _Metallic;
    float smoothness = metallicSmoothnessOcclusion.g * _Smoothness;
    float roughness = 1.0 - smoothness;
    // roughness = roughness * roughness;
    float occlusion = metallicSmoothnessOcclusion.b * _Occlusion;
    
	//detail skin mouth eye
	float4 detailMap = tex2D(_DetailMap, uv);
	float4 mouthDetailMap = tex2D(_MouthDetailMap, uv);
	float4 eyeDetailMap = tex2D(_EyeDetailMap, uv);
	float detailMask = detailMap.a;
	float mouthMask = mouthDetailMap.a;
	float eyeMask = eyeDetailMap.a;
	//uv
	float2 detailUV = uv;float2 mouthDetailUV = uv;float2 eyeDetailUV = uv;
	if(_DetailMapOn)
		 detailUV = uv * _DetailMap_ST.xy + _DetailMap_ST.zw;
	if(_MouthDetailMapOn)
		 mouthDetailUV = uv * _MouthDetailMap_ST.xy + _MouthDetailMap_ST.zw;
	if(_EyeDetailMapOn)
	     eyeDetailUV = uv * _EyeDetailMap_ST.xy + _EyeDetailMap_ST.zw;


    float3 tn = CalcNormal(uv,detailUV,mouthDetailUV,eyeDetailUV ,detailMask,mouthMask,eyeMask);
	
    float3 n = normalize(float3(
        dot(i.tSpace0.xyz,tn),
        dot(i.tSpace1.xyz,tn),
        dot(i.tSpace2.xyz,tn)
    ));
    float3 worldPos = float3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);
    float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
    float3 r = reflect(-v,n) + _ReflectionOffsetDir;

    float3 tangent = normalize(float3(i.tSpace0.x,i.tSpace1.x,i.tSpace2.x));
    float3 binormal = normalize(float3(i.tSpace0.y,i.tSpace1.y,i.tSpace2.y));

    float4 mainTex = CalcAlbedo(uv, detailUV, mouthDetailUV, eyeDetailUV,detailMask * _DetailMapIntensity,mouthMask*_MouthDetailMapIntensity,eyeMask*_EyeDetailMapIntensity);
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
    data.tangent = tangent;
    data.binormal = binormal;
    data.clothMask = 1;
    data.isClothOn = _ClothOn;
    data.isHairOn = _HairOn;

    if(_ClothMaskOn){
        data.clothMask = clothMask;
    }

    if(_HairOn){
        data.hairSpecColor = CalcHairSpecColor(i.uv,tangent,n,binormal,light.dir,v);
    }

    half4 c = CalcPBS(albedo, specColor, oneMinusReflectivity, smoothness, n, v, light, indirect,data);
    c.a = outputAlpha;
    
    c.rgb += CalcEmission(albedo,uv);

    if(_SSSOn){
        c.rgb += CalcSSS(uv,light.dir,v,frontSSS,backSSS);
    }
    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, c);
    return c;
}

#endif // SIMPLE_PBS_FORWARD_CGINC