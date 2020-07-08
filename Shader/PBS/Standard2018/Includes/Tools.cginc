#ifndef TOOLS_CGINC
#define TOOLS_CGINC

struct FastSSSData{
    float3 lightDir;
    float3 viewDir;
    float3 normal;
    float distortion,power,scale;
    float ambient,atten,thickness;
};

float FastSSS(FastSSSData data) {
    float3 h = normalize(data.lightDir + data.normal * data.distortion);
    float vh = pow(saturate(dot(data.viewDir, -h)), data.power) * data.scale;
    return (vh + data.ambient)* data.atten * data.thickness;
}

#if defined(_SPHERECLIP_ON)
	float4 _SphereClipInfo; //pos(xyz),dist(w)
	float _SphereClipSign;//0: 正向,1 :反向
    float _SphereClipBorderWidth;
    float4 _SphereClipBorderColor;
    float _SphereClipBorderColorScale;

void CheckSphereClip(float3 worldPos,out float3 borderColor){
    float sign = (_SphereClipSign - 0.5)*2; //[0,1] ->[-1,1]
    half dist = length(_SphereClipInfo.xyz - worldPos);
    half delta = (_SphereClipInfo.w - dist) * sign;
    clip(delta);

    half borderWidth = max(0,_SphereClipBorderWidth);
    half borderLerp = saturate((delta)/borderWidth );
    borderColor = lerp(_SphereClipBorderColor.rgb,(float3)0,step(1,borderLerp));
    borderColor = smoothstep(borderColor,0,borderLerp); //虚化边界,非全颜色会渐变
}

#endif


// end TOOLS_CGINC
#endif