// Upgrade NOTE: replaced 'defined SIMPLE_PBS_CORE_CGINC' with 'defined (SIMPLE_PBS_CORE_CGINC)'

#if !defined (SIMPLE_PBS_CORE_CGINC)
#define SIMPLE_PBS_CORE_CGINC

#define PI 3.1415926
#define INV_PI 0.31830988618f
#define DielectricSpec 0.04

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

int _DetailMapOn;
sampler2D _DetailMap;
float _DetailMapIntensity;
float4 _DetailMap_ST;
sampler2D _DetailNormalMap;
float _DetailNormalMapScale;
sampler2D _DetailMapMask;

samplerCUBE _EnvCube;
sampler2D _EnvCubeMask;
float _EnvIntensity;

sampler2D _EmissionMap;
float _Emission;
float _IndirectIntensity;

int _AlphaTestOn;
int _AlphaPreMultiply;

int _ClothOn;
float _ClothSpecWidthMin;
float _ClothSpecWidthMax;
int _ClothMaskOn;
sampler2D _ClothMaskMap;

// -------------------------------------- main light
#define MAX_SPECULAR 25
//---- 当前物体的光照
int _CustomLightOn;
fixed4 _LightDir;
fixed4 _LightColor;

float3 _MainLightDir;
float3 _MainLightColor;

int _SSSOn;
float3 _BackSSSColor,_FrontSSSColor;
sampler2D _SSSMask;
float _FrontSSSIntensity,_BackSSSIntensity;

// ----------------- parallel
int _ParallalOn;
sampler2D _HeightMap;
float _Height;

inline UnityLight GetLight(){
    float3 dir = _MainLightDir;
    float3 color = _MainLightColor;

    // ---- 改变主光源,方向,颜色.
    dir.xyz += _CustomLightOn > 0 ? _LightDir.xyz : 0;
    color += _CustomLightOn > 0 ?_LightColor : 0;
    dir = normalize(dir);

    UnityLight l = {color.rgb,dir.xyz,0};
    return l;
}


inline float FastSSS(float3 l,float3 v){
    return saturate(dot(l,v));
}

inline float3 CalcSSS(float2 uv,float3 l,float3 v){
    float4 sssMask = tex2D(_SSSMask,uv);
    float sss1 = FastSSS(l,v);
    float sss2 = FastSSS(-l,v);
    float3 front = sss1 * _FrontSSSIntensity * sssMask.x * _FrontSSSColor;
    float3 back = sss2 * _BackSSSIntensity * sssMask.y * _BackSSSColor;
    return (front + back);
}


inline float3 GetIndirectSpecular(float3 reflectDir,float rough){
    rough = rough *(1.7 - rough * 0.7);
    float mip = rough * 6;
    float4 rgbm = texCUBElod(_EnvCube,float4(reflectDir,mip));
    return DecodeHDR(rgbm,unity_SpecCube0_HDR);
}


inline half3 AlphaPreMultiply (half3 diffColor, half alpha, half oneMinusReflectivity, out half outModifiedAlpha)
{
    if(_AlphaPreMultiply){
        diffColor *= alpha;

        #if (SHADER_TARGET < 30)
            outModifiedAlpha = alpha;
        #else
            outModifiedAlpha = 1-oneMinusReflectivity + alpha*oneMinusReflectivity;
        #endif
    }else{
        outModifiedAlpha = alpha;
    }
    return diffColor;
}

inline float2 Parallax(float2 uv,float3 viewTangentSpace){
    if(_ParallalOn){
        float h = tex2D(_HeightMap,uv).g;
        uv += ParallaxOffset(h,_Height,viewTangentSpace);
    }
    return uv;
}

inline float3 CalcNormal(float2 uv,float detailMask){
    float2 detailUV = uv * _DetailMap_ST.xy + _DetailMap_ST.zw;
    float3 tn = UnpackScaleNormal(tex2D(_NormalMap,detailUV),_NormalMapScale);
    if(_DetailMapOn){
        
        float3 dtn = UnpackScaleNormal(tex2D(_DetailNormalMap,detailUV),_DetailNormalMapScale);
        dtn = BlendNormals(tn,dtn);
        tn = lerp(tn,dtn,detailMask);
    }
    return tn;
}

inline float4 CalcAlbedo(float2 uv,float detailMask){
    float4 albedo = tex2D(_MainTex,uv) * _Color;
    if(_DetailMapOn){
        float3 detailAlbedo = tex2D(_DetailMap,uv);
        albedo.rgb *= lerp(1,detailAlbedo * unity_ColorSpaceDouble.rgb,detailMask);
    }
    return albedo;
}

inline UnityIndirect CalcGI(float3 albedo,float2 uv,float3 reflectDir,float3 normal,float occlusion,float roughness){
    float indirectSpecularMask = tex2D(_EnvCubeMask,uv).b;
    float3 indirectSpecular = GetIndirectSpecular(reflectDir,roughness) * occlusion * _EnvIntensity * indirectSpecularMask;
    float3 indirectDiffuse = albedo * occlusion * _IndirectIntensity;
    indirectDiffuse += ShadeSH9(float4(normal,1));
    UnityIndirect indirect = {indirectDiffuse,indirectSpecular};
    return indirect;
}

float RoughnessToSpecPower(float a){
    float a2 = a * a;
    float sq = max(1e-4f,a2 * a2);
    float n = 2.0/sq - 2;
    n = max(n,1e-4f);
    return n;
}

float SmithJointGGXTerm(float nl,float nv,float a2){
    float v = nv * (nv * (1-a2)+a2);
    float l = nl * (nl * (1-a2)+a2);
    return 0.5f/(v + l + 1e-5f);
}

float NDFBlinnPhongTerm(float nh,float a){
    float normTerm = (a + 2)* 0.5/PI;
    float specularTerm = pow(nh,a);
    return normTerm * specularTerm;
}

float D_GGXTerm(float nh,float a){
    float a2 = a  * a;
    float d = (nh*a2-nh)*nh + 1;
    return INV_PI * a2 / (d*d + 1e-7f);
}

float3 FresnelTerm(float3 F0,float lh){
    return F0 + (1-F0) * Pow5(1 - lh);
}
float3 FresnelLerp(float3 f0,float3 f90,float lh){
    float t = Pow5(1-lh);
    return lerp(f0,f90,t);
}
float3 FresnelLerpFast(float3 F0,float3 F90,float lh){
    float t = Pow4(1 - lh);
    return lerp(F0,F90,t);
}

float D_GGXAnisoNoPI(float TdotH, float BdotH, float NdotH, float roughnessT, float roughnessB)
{
    float a2 = roughnessT * roughnessB;
    float3 v = float3(roughnessB * TdotH, roughnessT * BdotH, a2 * NdotH);
    float  s = dot(v, v);

    // If roughness is 0, returns (NdotH == 1 ? 1 : 0).
    // That is, it returns 1 for perfect mirror reflection, and 0 otherwise.
    return (a2 * a2 * a2)/ (s * s);
}

float BankBRDF(float3 l,float3 v,float3 t,float ks,float power){
    float lt = dot(l,t);
    float vt = dot(v,t);
    float lt2 = lt*lt;
    float vt2 = vt*vt;
    return ks * pow(sqrt(1-lt2)*sqrt(1-vt2) - lt*vt,power);
}

float Cloth(float nv,float clothMask){
    float offset = smoothstep(_ClothSpecWidthMin,_ClothSpecWidthMax,nv);
    // float offsetMask = smoothstep(0.3,0.31,smoothness);
    return saturate(offset) * clothMask;
}

struct PBSData{
    float3 tangent;
    float3 bitangent;
    float clothMask;
};

inline float4 PBS(float3 diffColor,half3 specColor,float oneMinusReflectivity,float smoothness,
    float3 normal,float3 viewDir,
    UnityLight light,UnityIndirect gi,PBSData data){

    float a = 1- smoothness;
    float a2 = a*a;
    a2 = max(0.002,a2);
    
    float3 l = normalize(light.dir);
    float3 n = normalize(normal);
    float3 v = normalize(viewDir);
    float3 h = normalize(l + v);
    float3 t = normalize(data.tangent);
    float3 tb = normalize(data.bitangent);

    float nh = saturate(dot(n,h));
    float nl = saturate(dot(n,l));
    float nv = abs(dot(n,v));
    float lv = saturate(dot(l,v));
    float lh = saturate(dot(l,h));

    if(_ClothOn){
        float offset = Cloth(nv,data.clothMask);
        nh += offset;
        a2 = offset;
    }
    // -------------- diffuse part
    float diffuseTerm = DisneyDiffuse(nv,nl,lh,a) * nl;
    // float diffuseTerm = nl;
    float3 directDiffuse = light.color * diffuseTerm;
    float3 indirectDiffuse = gi.diffuse;
    float3 diffuse = (directDiffuse + indirectDiffuse) * diffColor;

    // -------------- specular part
    float V = SmithJointGGXTerm(nl,nv,a2);
    //float D = NDFBlinnPhongTerm(nh,RoughnessToSpecPower(a));
    float D = D_GGXTerm(nh,a2);
    float3 F = FresnelTerm(specColor,lh);

    float3 specularTerm = V * D * PI * nl;
    specularTerm = max(0,specularTerm);
    specularTerm *= any(specColor)?1:0;

    float surfaceReduction =1 /(a2 * a2+1);
    float grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));

    float3 directSpecular = specularTerm * light.color * F;
    float3 indirecSpecular = surfaceReduction * gi.specular * FresnelLerpFast(specColor,grazingTerm,nv);
    float3 specular = directSpecular + indirecSpecular;
    return float4(diffuse + specular,1);
}

#endif // end of SIMPLE_PBS_CORE_CGINC