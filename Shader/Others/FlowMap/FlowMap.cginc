#if !defined(FLOW_MAP_CGINC)
#define FLOW_MAP_CGINC

/** version 1
    result = (uv,scale,flowLerp)
*/
float4 Flow(float2 uv,float2 flowVec,float time,bool flowB,float tiling){
    float phase = flowB? 0.5:0;
    float p = frac(time + phase);

    float4 uvst = (float4)0;
    uvst.xy = uv - flowVec * p;
    uvst.xy *= tiling ;//*(1 - length(flowVec))
    uvst.xy += phase;
    uvst.z = 1 - abs(1 - 2 * p);
    uvst.w = p;
    return uvst;
}

float4 FlowColor(sampler2D tex,float2 uv,float2 flowVec,float tiling){
    float4 uvst1 = Flow(uv,flowVec,_Time.y,true,tiling);
    float4 uvst2 = Flow(uv,flowVec,_Time.y,false,tiling);

    float4 c = tex2D(tex,uvst1.xy) * uvst1.z;
    float4 c2 = tex2D(tex,uvst2.xy) * uvst2.z;
    return c+c2;
}

/** version 2
    result = (uv,flowLerp)
*/
float3 ApplyFlow(float2 uv,float2 flowVec,float time,bool flowB){
    float phase = flowB ? 0.5 :0;
    float p = frac(time + phase);
    float3 result = float3(0,0,0);
    result.xy = uv - flowVec * p;
    result += phase;
    result.z = p;
    return result;
}

float4 ApplyFlowColor(sampler2D tex,float2 uv,float2 flowVec){
    float3 uvt = ApplyFlow(uv,flowVec,_Time.y,true);
    float3 uvt2 = ApplyFlow(uv,flowVec,_Time.y,false);
    float flowLerp = abs( (0.5 - uvt.z)/0.5);
    float4 c = tex2D(tex,uvt.xy);
    float4 c2 = tex2D(tex,uvt2.xy);
    return lerp(c,c2,flowLerp);
}
#endif //FLOW_MAP_CGINC