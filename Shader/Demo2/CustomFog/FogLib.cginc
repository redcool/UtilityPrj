#if !defined(FOG_LIB_CGINC)
#define FOG_LIB_CGINC

#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    #define USING_FOG
#endif

sampler2D _ExploredTex;
sampler2D _FogMainNoiseMap,_FogDetailNoiseMap;
sampler2D _HighlightTex;

float3 _SceneMin;
float3 _SceneMax;

float4 _FogNoiseTilingOffset;
float4 _HighlightColor;
float _StartExploreTime;
float _ExploreFogFadeTime;


float4 GetVertexFogFactor(float3 worldPos){
    float3 uv = (worldPos - _SceneMin.xyz) / (_SceneMax.xyz - _SceneMin.xyz);
    float4 exploredTex = tex2Dlod(_ExploredTex,float4(uv.xz,0,0));
    // fade 
    float fadeRate = (_Time.y - _StartExploreTime)/_ExploreFogFadeTime;
    fadeRate = lerp(exploredTex.b,exploredTex.g,saturate(fadeRate));
    return float4(uv,fadeRate);
}

//unity_FogColor
float4 CalcFogColor(float3 worldPos){
    float2 noiseUV = frac(worldPos.xz * _FogNoiseTilingOffset.xy + _Time.y * _FogNoiseTilingOffset.zw);
    float4 detailNoise = tex2D(_FogDetailNoiseMap,noiseUV);

    // high light
    float4 highlightTex = tex2D(_HighlightTex,worldPos.xz);
    float highlight = abs(sin(_Time.y)) * highlightTex.x;

    float4 mainNoise = tex2D(_FogMainNoiseMap,noiseUV + detailNoise.xy*0.2);
    return mainNoise * unity_FogColor + highlight * _HighlightColor;
}

#if defined(USING_FOG)
    #define UNITY_FOG_COORDS(idx) float4 fogCoord:TEXCOORD##idx;
    #define UNITY_TRANSFER_FOG(o,outpos) o.fogCoord = GetVertexFogFactor(o.posWorld);
    #define UNITY_APPLY_FOG(fogCoord,col) col.rgb = lerp(col, CalcFogColor(fogCoord.xyz),fogCoord.w)
#else
    #define UNITY_FOG_COORDS(idx)
    #define UNITY_TRANSFER_FOG(o,outpos)
    #define UNITY_APPLY_FOG(fogCoord,col)
#endif

#endif //FOG_LIB_CGINC