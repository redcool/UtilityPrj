#if !defined(NOISE_LIB_CGINC)    
#define NOISE_LIB_CGINC

float noise(float2 p,float frequency,float amplitude){
    return frac( sin(dot(p,float2(123,7890)) * frequency) *amplitude);
}

float noise(float2 p){
    return noise(p,1,10000);
}

float smoothNoise(float2 uv){
    float n = noise(uv);
    float2 lv =frac(uv);
    lv = smoothstep(0,1,lv);
    float2 id = floor(uv);

    float bl = noise(id);
    float br = noise(id + float2(1,0));
    float b = lerp(bl,br,lv.x);

    float tl = noise(id + float2(0,1));
    float tr = noise(id + float2(1,1));
    float t = lerp(tl,tr,lv.x);
    return lerp(b,t,lv.y);
}

float smoothNoise2(float2 uv){
    float c = smoothNoise(uv * 4);
    c += smoothNoise(uv * 8) * 0.5;
    c += smoothNoise(uv * 16) * 0.25;
    c += smoothNoise(uv * 32) * 0.125;
    c += smoothNoise(uv * 64) * 0.0625;
    return c/2;
}

float Hash21(float2 p){
    p =frac(p * float2(123.34,456.21));
    p += dot(p,p + 45.32);
    return frac(p.x * p.y);
}

float2 hash22(float2 p) {
    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
    return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

float2 hash21(float2 p) {
    float h = dot(p, float2(127.1, 311.7));
    return -1.0 + 2.0 * frac(sin(h) * 43758.5453123);
}

//perlin
float perlin_noise(float2 p) {
    float2 pi = floor(p);
    float2 pf = p - pi;
    float2 w = pf * pf * (3.0 - 2.0 * pf);
    return lerp(lerp(dot(hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
        dot(hash22(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)), w.x),
        lerp(dot(hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
            dot(hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x), w.y);
}
#endif //NOISE_LIB_CGINC