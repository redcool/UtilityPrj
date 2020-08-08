#if !defined(LIGHT_LIB_CGINC)
#define LIGHT_LIB_CGINC

float BandStep(float nl,float step){
	float seg = step / 10;
	return floor(nl * 10 / step) * seg;
}

float StepLight(float nl,float width){
	return smoothstep(0,width,nl)+ 0.33;
}

float4 _Specular; // 4 point lights specular intensity
float4 _Gloss; //4 point lights glosses

float3 PointLights(float3 posWorld,float3 normalDir,float3 viewDir){
    float3 c = (float3)0;
    for (int index = 0; index < 4; index++)
    {  
        float4 lightPosition = float4(unity_4LightPosX0[index], unity_4LightPosY0[index], unity_4LightPosZ0[index], 1.0);

        float3 vertexToLightSource = lightPosition.xyz - posWorld.xyz;    
        float3 lightDirection = normalize(vertexToLightSource);
        float squaredDistance = dot(vertexToLightSource, vertexToLightSource);
        float attenuation = 1.0 / (1.0 + unity_4LightAtten0[index] * squaredDistance);
        float3 diffuseReflection = attenuation * unity_LightColor[index].rgb  * max(0.0, dot(normalDir, lightDirection));     

        float specular =max(0.001, _Specular[index]);
        float gloss = _Gloss[index];
        float3 h = normalize(lightDirection + viewDir);
        float3 specReflection = pow(saturate(dot(normalDir,h)) ,128 * specular) * gloss * max(0.0, dot(normalDir, lightDirection));

        c += diffuseReflection + specReflection;
    }
    return c;
}


#endif //LIGHT_LIB_CGINC