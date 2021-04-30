
float3 BoxProjection(float3 refDir,float3 boxMin,float3 boxMax,float3 worldPos,float3 boxCenter){
    float3 invRefDir = 1/refDir;
    float3 intersecAtMax = (boxMax - worldPos) * invRefDir;
    float3 intersecAtMin = (boxMin - worldPos) * invRefDir;
    float3 maxIntersec = max(intersecAtMax,intersecAtMin);
    float dist = min(min(maxIntersec.x,maxIntersec.y),maxIntersec.z);
    float3 intersecPos = worldPos + refDir * dist;
    return intersecPos - boxCenter;
}