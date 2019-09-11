#ifndef CONVOLUTION_LIB_CGINC
#define CONVOLUTION_LIB_CGINC
static int weights[9] = {-1,-1,-1,-1,8,-1,-1,-1,-1};
static int2 coords[9] = {int2(-1,-1),int2(0,-1),int2(1,-1),int2(-1,0),int2(0,0),int2(1,0),int2(-1,1),int2(0,1),int2(1,1)};

float4 Border(sampler2D tex,float4 texel, float2 uv) {
    float4 c = (float4)0;
    for(int i=0;i<9;i++){
        c += tex2D(tex,uv + coords[i]*texel.xy) * weights[i];
    }
    return c;
}

// end 
#endif