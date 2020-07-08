#if !defined(PBS_CORE_CGINC)
#define PBS_CORE_CGINC

float GSF1(float nl,float nv){
    return nl * nv;
}

float BlinnPhongNormalDistribution(float NdotH, float specularpower, float speculargloss){
    float Distribution = pow(NdotH,speculargloss) * specularpower;
    Distribution *= (2+specularpower) / (2*3.1415926535);
    return Distribution;
}

#endif //end of PBS_CORE_CGINC