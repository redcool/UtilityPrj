#ifndef WAVE_INCLUDE_CGINC
#define WAVE_INCLUDE_CGINC

sampler2D _WaveTex;
float4 _WaveColor;
float _WaveColorSaturation;
float _WaveSpeed;
float _Bright;
float _BrightThreshold;
float _RimPower;

sampler2D _WaveTex2;
float4 _WaveColor2;
float _WaveSpeed2;

float Gray(float3 c){
    return dot(float3(0.02,0.7,0.2),c);
}

float4 SampleWaveTex(sampler2D tex, float2 uv, float2 uvDir, float waveSpeed, float4 color) {
    uv += uvDir * _Time.y * waveSpeed;
    return tex2D(tex, uv).a * color;
}

float4 GetMainWaveColor(float3 worldPos, float2 mainUV, float nv) {
    float2 uv = (worldPos.xy * 2) ;
    fixed4 waveTex = SampleWaveTex(_WaveTex, uv, float2(0, 1), _WaveSpeed, _WaveColor);

    fixed4 waveCol = waveTex;
    waveCol += SampleWaveTex(_WaveTex, worldPos.yz, float2(0, 1), _WaveSpeed, _WaveColor);

    //waveCol.rgb = lerp(waveCol,waveCol*0.4,step(g, _BrightThreshold));
    waveCol.rgb = lerp(waveCol, waveCol*0.4, _BrightThreshold);

    fixed gray = Gray(waveCol.rgb);
    waveCol.rgb = lerp((fixed3)gray, waveCol.rgb, _WaveColorSaturation);
    waveCol.rgb *= pow(nv, _RimPower);
    return waveCol * waveCol.a;
}


fixed3 BlendWave(float3 worldNormal,float3 worldPos,float2 uv){
    float3 n = worldNormal;
    float3 v = normalize(_WorldSpaceCameraPos.xyz - worldPos);
    float nv = dot(n, v);
    //float invertNV = 1 - nv;					
    fixed4 waveCol = GetMainWaveColor(worldPos,uv,nv);

    fixed4 waveCol2 = SampleWaveTex(_WaveTex2, worldPos.xy,float2(1,0), _WaveSpeed2, _WaveColor2);
    waveCol2.rgb *= waveCol2.a;
    return (waveCol.rgb + waveCol2.rgb) * _Bright;
}

#endif