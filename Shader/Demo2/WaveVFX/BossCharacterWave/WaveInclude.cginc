#ifndef WAVE_INCLUDE_CGINC
#define WAVE_INCLUDE_CGINC

UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(float4, _WaveColor)
    UNITY_DEFINE_INSTANCED_PROP(float, _WaveColorSaturation)
    UNITY_DEFINE_INSTANCED_PROP(float, _WaveSpeed)
    UNITY_DEFINE_INSTANCED_PROP(float, _Bright)
    UNITY_DEFINE_INSTANCED_PROP(float, _BrightThreshold)
    UNITY_DEFINE_INSTANCED_PROP(float, _RimPower)

    UNITY_DEFINE_INSTANCED_PROP(float4, _WaveColor2)
    UNITY_DEFINE_INSTANCED_PROP(float, _WaveSpeed2)
UNITY_INSTANCING_BUFFER_END(Props)

sampler2D _WaveTex;
sampler2D _WaveTex2;

float Gray(float3 c){
    return dot(float3(0.02,0.7,0.2),c);
}

float4 SampleWaveTex(sampler2D tex, float2 uv, float2 uvDir, float waveSpeed, float4 color) {
    uv += uvDir * _Time.y * waveSpeed;
    return tex2D(tex, uv).a * color;
}

float4 GetMainWaveColor(float3 worldPos, float2 mainUV, float nv) {
    // fro instancing prop
    float4 waveColor = UNITY_ACCESS_INSTANCED_PROP(Props, _WaveColor);
    float waveSpeed = UNITY_ACCESS_INSTANCED_PROP(Props, _WaveSpeed);
    float brightThreshold = UNITY_ACCESS_INSTANCED_PROP(Props, _BrightThreshold);
    float waveColorSaturation = UNITY_ACCESS_INSTANCED_PROP(Props, _WaveColorSaturation);
    float rimPower = UNITY_ACCESS_INSTANCED_PROP(Props, _RimPower);

    float2 uv = (worldPos.xy * 2) ;
    fixed4 waveTex = SampleWaveTex(_WaveTex, uv, float2(0, 1), waveSpeed, waveColor);

    fixed4 waveCol = waveTex;
    waveCol += SampleWaveTex(_WaveTex, worldPos.yz, float2(0, 1), waveSpeed, waveColor);

    //waveCol.rgb = lerp(waveCol,waveCol*0.4,step(g, brightThreshold));
    waveCol.rgb = lerp(waveCol, waveCol*0.4, brightThreshold);

    fixed gray = Gray(waveCol.rgb);
    waveCol.rgb = lerp((fixed3)gray, waveCol.rgb, waveColorSaturation);
    waveCol.rgb *= pow(nv, rimPower);
    return waveCol * waveCol.a;
}


fixed3 BlendWave(float3 worldNormal,float3 worldPos,float2 uv){
    //for instancing props
    float waveSpeed2 = UNITY_ACCESS_INSTANCED_PROP(Props, _WaveSpeed2);
    float4 waveColor2 = UNITY_ACCESS_INSTANCED_PROP(Props, _WaveColor2);
    float bright = UNITY_ACCESS_INSTANCED_PROP(Props, _Bright);


    float3 n = worldNormal;
    float3 v = normalize(_WorldSpaceCameraPos.xyz - worldPos);
    float nv = dot(n, v);
    //float invertNV = 1 - nv;					
    fixed4 waveCol = GetMainWaveColor(worldPos,uv,nv);

    fixed4 waveCol2 = SampleWaveTex(_WaveTex2, worldPos.xy,float2(1,0), waveSpeed2, waveColor2);
    waveCol2.rgb *= waveCol2.a;
    return (waveCol.rgb + waveCol2.rgb) * bright;
}

#endif