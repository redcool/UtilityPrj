#ifndef STRAND_SPEC_CGINC
#define STRAND_SPEC_CGINC

#if defined(_HAIRSPEC_ON)
sampler2D _HairSpecMaskMap;
sampler2D _HairShiftMap;
float _HairShift1;
float _HairShift2;
float3 _HairColor1;
float3 _HairColor2;
float _HairSpecPower1;
float _HairSpecPower2;
float _HairSpecIntensity1;
float _HairSpecIntensity2;
float _HairTangentRot;


float3 ShiftTangent(float3 t,float3 n,float shift){
    return normalize(t + n * shift);
}
float StrandSpecular(half3 t, half3 h, float exponent)
{
    float th = dot(t,h);
    float sinTH = sqrt(1.0 - th * th);
    float dirAtten = smoothstep(-1,0,th);
    return dirAtten * pow(sinTH,exponent);
}

struct StrandSpecData{
    float specMask;
    float hairShiftMap;

    float3 tangent;
    float3 normal;
    float3 worldPos;
    float shift1;
    float shift2;
    float3 specColor1;
    float3 specColor2;
    float specPower1;
    float specPower2;
    float specIntensity1;
    float specIntensity2;
    //---- output
    float hairSpecularTerm; // used in UnityCustomStandardBRDF.cginc
};

StrandSpecData strandSpecData;

float3 ComputeStrandSpec(StrandSpecData data){
    float3 l = UnityWorldSpaceLightDir(data.worldPos);
    float3 v = UnityWorldSpaceViewDir(data.worldPos);

    float3 t1 = ShiftTangent(data.tangent,data.normal,data.shift1 + data.hairShiftMap);
    float3 t2 = ShiftTangent(data.tangent,data.normal,data.shift2 + data.hairShiftMap);

    float3 h = normalize(l+v);
    
    float3 spec1 = StrandSpecular(t1,h,data.specPower1) * data.specColor1 * data.specIntensity1;

    float3 spec2 = StrandSpecular(t2,h,data.specPower2) * data.specColor2 * data.specIntensity2;

    float nl = dot(data.normal,l) * 0.5+0.5;
    return (spec1+spec2) * data.specMask * nl;
}

void ComputeStrandSpec(float2 uv,float3 tangent,float3 normal,float3 worldPos){
    strandSpecData = (StrandSpecData)0;
    strandSpecData.specMask = tex2D(_HairSpecMaskMap,uv).r;
    strandSpecData.hairShiftMap = tex2D(_HairShiftMap,uv).g;
    strandSpecData.tangent = tangent;
    strandSpecData.normal = normal;
    strandSpecData.worldPos = worldPos;
    strandSpecData.specPower1 = _HairSpecPower1;
    strandSpecData.specPower2 = _HairSpecPower2;
    strandSpecData.shift1 = _HairShift1;
    strandSpecData.shift2 = _HairShift2;
    strandSpecData.specPower1 = _HairSpecPower1;
    strandSpecData.specPower2 = _HairSpecPower2;
    strandSpecData.specIntensity1 = _HairSpecIntensity1;
    strandSpecData.specIntensity2 = _HairSpecIntensity2;
    strandSpecData.hairSpecularTerm = ComputeStrandSpec(strandSpecData);
}

#endif// end _HAIRSPEC_ON

#endif // end STRAND_SPEC_CGINC