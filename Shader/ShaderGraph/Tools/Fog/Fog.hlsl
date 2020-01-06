#if !defined(FOG_HLSL)
#define FOG_HLSL

void ComputeFog_half(float2 distanceFog,float2 heightFog,float3 worldPos,float3 cameraPos,out float fogFactor){
    float dist = distance(worldPos,cameraPos);
    float factor = saturate( (dist - distanceFog.x)/(distanceFog.y-distanceFog.x) );
    float heightFactor = saturate( (worldPos.y - heightFog.x)/(heightFog.y-heightFog.x));
    fogFactor = heightFactor * factor;
}

#endif //FOG_HLSL