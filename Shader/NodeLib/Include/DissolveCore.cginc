#if !defined(DISSOLVE_CORE_CGINC)
#define DISSOLVE_CORE_CGINC

int _DissolveDirectionX;
int _DissolveReverseOn;
float _DissolveIntensity;
float _DissolveBaseY;
float _DissolveHeight;
sampler2D _DissolveNoiseMap;
float _DissolveNoiseScale;
float _DissolveEdgeWidth;
float4 _DissolveEdgeColor;

/**
    DissolveClip
    parameter : posWorld,uv
    return : heightDiff color
*/
float4 DissolveClip(float3 posWorld,float2 uv){
    float4 noiseMap = tex2D(_DissolveNoiseMap,uv);
    float noise = noiseMap.x * _DissolveNoiseScale;
    noise *= _DissolveReverseOn ? (_DissolveIntensity) : 1;  // reverse handle

    float curPos = _DissolveDirectionX == 1 ? posWorld.x : posWorld.y;
    float posY = curPos - _DissolveBaseY;
    float targetY = _DissolveIntensity * _DissolveHeight;

    float heightDiff = posY - targetY;
    heightDiff = _DissolveReverseOn? targetY - posY : heightDiff; // reverse it
    heightDiff += noise;

    clip(heightDiff);

    float halfWidth = _DissolveEdgeWidth/2;
    float v = saturate(abs(heightDiff/halfWidth));

    return lerp(_DissolveEdgeColor,float4(1,1,1,1),saturate(v));
}
#endif //end of DISSOLVE_CORE_CGINC