
    float3 BoxProjection(float3 refDir,float3 boxMin,float3 boxMax,float3 worldPos,float3 boxCenter){
        float3 invRefDir = 1/refDir;
        float3 intersecAtMax = (boxMax - worldPos) * invRefDir;
        float3 intersecAtMin = (boxMin - worldPos) * invRefDir;
        float3 maxIntersec = max(intersecAtMax,intersecAtMin);
        float dist = min(min(maxIntersec.x,maxIntersec.y),maxIntersec.z);
        float3 intersecPos = worldPos + refDir * dist;
        return intersecPos - boxCenter;
    }

    float4 PlanarShadowPos(float4 worldPos,float planeHeight,float4 lightDir){
        lightDir = -normalize(lightDir);
        float cosTheta = -lightDir.y;
        float adjLen = worldPos.y - planeHeight;
        float hypotenuse = adjLen/cosTheta;
        worldPos += lightDir * hypotenuse;
        return float4(worldPos.x,planeHeight,worldPos.z,1);
    }