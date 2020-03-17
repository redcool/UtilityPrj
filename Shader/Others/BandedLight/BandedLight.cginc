#if !defined(BANDED_LIGHT_CGINC)
#define BANDED_LIGHT_CGINC

float StepBandedLight(float3 normal,float3 lightDir,float minBright,int steps){
    float nl = dot(normal,lightDir) * 0.5 + 0.5;
    nl = floor(nl * steps)/steps;
    nl += minBright;
    return nl;
}


float SmoothBandedLight(float3 normal,float3 lightDir,float minBright,float maxBright){
    float nl = dot(normal,lightDir);
    nl = smoothstep(0,maxBright,nl) + minBright;
    return nl;
}

#endif //BANDED_LIGHT_CGINC