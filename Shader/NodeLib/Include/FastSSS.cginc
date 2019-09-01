#ifndef FASTSSS_CGINC
#define FASTSSS_CGINC

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

#endif