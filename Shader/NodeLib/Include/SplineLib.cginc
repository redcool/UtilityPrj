#if !defined(SPLINE_LIB_CGINC)
#define SPLINE_LIB_CGINC

float SinLine(float2 uv){
    float2 xy = (uv.xy) * 6.28;
    float s= abs(sin(xy.x) - xy.y); // sin,cos,tan, is ok
    return smoothstep(0.01,0.,s);
}

float Line(float2 uv){
    return smoothstep(0.001,0,abs(uv.x));
}
float SlideLine(float v,float progress){
    float t = abs(v - progress);
    return smoothstep(0.01,0.001,t);
}
#endif //SPLINE_LIB_CGINC