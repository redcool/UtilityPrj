#ifndef FASTSSSCORE_CGINC
#define FASTSSSCORE_CGINC

struct FastSSSData{
    float3 lightDir;
    float3 viewDir;
    float3 normal;
    float normalDistortion,power,scale;
    float ambient,atten,thickness;
};

float FastSSS(FastSSSData data) {
    float3 h = normalize(data.lightDir + data.normal * data.normalDistortion);
    float vh = pow(saturate(dot(data.viewDir, -h)), data.power) * data.scale;
    return (vh + data.ambient)* data.atten * data.thickness;
}

#endif 