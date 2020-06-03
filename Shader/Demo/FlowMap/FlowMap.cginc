#if !defined(FLOW_MAP_CGINC)
#define FLOW_MAP_CGINC

/** version 1
    result = (uv,scale,flowLerp)
*/
float3 CalcFlow(float2 mainUV,float2 flowVec,float time,bool flowB,float speed){
    float phase = flowB?0.5:0;
    float p = frac(time + phase);
    float2 result = mainUV - flowVec * p * speed;
    float scale = abs((0.5-p)/0.5);
    return float3(result, scale);
}

float4 FlowColor(sampler2D flowTex,sampler2D tex,float2 uv,float tiling,float speed){
    float4 flowMap = tex2D(flowTex,uv);
    float2 flowVec = flowMap.xy * 2 -1;

    float3 flow = CalcFlow(uv,flowVec,_Time.y,true,speed);
    float3 flow2 = CalcFlow(uv,flowVec,_Time.y,false,speed);

    float4 c = tex2D(tex,flow.xy);
    float4 c2 = tex2D(tex,flow2.xy);
    float4 col = lerp(c,c2,flow.z);
    return col;
}

/** version 2
    result = (uv,flowLerp)
*/
float3 Flow2(float2 uv,float2 flowVec,float time,bool flowB,float tiling){
    float phase = flowB ? 0.5 :0;
    float p = frac(time + phase);
    float flowLerp = abs((0.5-p)/0.5);
    float3 result = float3(0,0,0);
    result.xy = uv - flowVec * p;
    result.xy *= tiling;
    //result += phase;
    result.z = flowLerp;
    return result;
}

float4 FlowColor2(sampler2D tex,float2 uv,float2 flowVec,float tiling){
    float3 flow = Flow2(uv,flowVec,_Time.y,true,tiling);
    float3 flow2 = Flow2(uv,flowVec,_Time.y,false,tiling);
    float4 c = tex2D(tex,flow.xy);
    float4 c2 = tex2D(tex,flow2.xy);
    return lerp(c,c2,flow.z);
}
#endif //FLOW_MAP_CGINC