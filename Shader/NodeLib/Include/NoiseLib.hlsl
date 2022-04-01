#if !defined(NOISE_LIB_HLSL)
#define NOISE_LIB_HLSL

half SmoothBanded(half nl,half count,half edgeMin,half edgeMax){
    half id = floor(nl * count);
    half f = frac(nl * count);
    return lerp(id,id+1,smoothstep(edgeMin,edgeMax,f))/count;
}

half Random(half2 st){
    return frac(sin(dot(st,half2(12.789,78.123))) * 45678.1234);
}
half Random2(half2 st){
    st = half2(
        dot(st,half2(127.1,311.89)),
        dot(st,half2(289.123,184.234))
    );
    return frac(sin(st) * 4315.123)*2-1;
}

half ValueNoise(half2 st){
    half2 i = floor(st);
    half2 f = frac(st);

    float a = Random(i);
    float b = Random(i + half2(1,0));
    float c = Random(i + half2(0,1));
    float d = Random(i + half2(1,1));
// f = clamp(((f-0.1)/(0.8-0.1)),0,1);
    float2 uv = f*f*(3-2*f);
    half hb = lerp(a,b,uv.x);
    half ht = lerp(c,d,uv.x);
    return lerp(hb,ht,uv.y);
}

half SmoothValueNoise(half2 st){
    half n = ValueNoise(st * 4) + 
            ValueNoise(st * 8) * 0.5 +
            ValueNoise(st * 16) * 0.25 + 
            ValueNoise(st * 32) * 0.125 + 
            ValueNoise(st * 65) * 0.06125;
    return n*0.5;
}

half SmoothValueNoiseKen(half2 st){
    half2 i = floor(st);
    half2 f = frac(st);
    half2 u = f*f*(3-2*f);
    return lerp(
        lerp(dot(Random2(i),f),dot(Random2(i+half2(1,0)),f - half2(1,0)),u.x),
        lerp(dot(Random2(i+half2(0,1)),f - half2(0,1)),dot(Random2(i+half2(1,1)),f - half2(1,1)),u.x),
        u.y
    );
}

#endif // NOISE_LIB_HLSL