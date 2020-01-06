#if !defined(STRAND_SPEC_HLSL)
#define STRAND_SPEC_HLSL

float3 shiftTangent(float3 t,float3 n,float shift){
    return normalize(t + n * shift);
}

float StrandSpecular(float3 t,float3 v,float3 l,float exponent){
    float3 h = normalize(l+v);
    float th = dot(t,h);
    float sinTH = sqrt(1.0 - th * th);
    float dirAtten = smoothstep(-1,0,th*0.5+0.5);
    return dirAtten * pow(sinTH,exponent);
}

void HairLighting_half(float3 tangent,float3 normal,float3 lightDir,float3 viewDir,float2 uv,
    Texture2D<float4> _ShiftTex,SamplerState  _ShiftTexSampler,float4 shift2_Exponent2,float3 specColor1,float3 specColor2,
    out float3 result
){
    float shiftTex = _ShiftTex.Sample(_ShiftTexSampler,uv) - 0.5;
    float3 t1 = shiftTangent(tangent,normal,shiftTex * shift2_Exponent2.x);
    float3 t2 = shiftTangent(tangent,normal,shiftTex * shift2_Exponent2.y);

    float3 spec1 = StrandSpecular(t1,viewDir,lightDir,shift2_Exponent2.z);
    float3 spec2 = StrandSpecular(t2,viewDir,lightDir,shift2_Exponent2.w);
    result = spec1 * specColor1 + spec2 * specColor2;
}



#endif //STRAND_SPEC_HLSL