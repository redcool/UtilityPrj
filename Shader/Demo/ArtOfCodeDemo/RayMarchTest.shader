Shader "Unlit/RayMarchTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CenterRadius("_CenterRadius",vector) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        // cull back

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _CenterRadius;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURF_DIST 0.01
float GetDist(float3 p){
    float3 sphere = float3(0,2,4);
    float radius = 1;
    float sphereDist = distance(sphere,p) - radius;
    float planeDist = p.y;
    // return saturate(planeDist * sphereDist);
    return min(planeDist,sphereDist);
}

float3 GetNormal(float3 p){
    float d = GetDist(p);
    float2 e = float2(0.01,0);
    float3 n = d- float3(
        GetDist(p - e.xyy),
        GetDist(p - e.yxy),
        GetDist(p - e.yyx)
    );
    return normalize(n);
}
float Raymarch(float3 ro,float3 rd){
    float d0 = 0;
    for(int i=0;i<MAX_STEPS;i++){
        float3 p = ro + rd * d0;
        d0 += GetDist(p);
        if(d0 > MAX_DIST || d0 < SURF_DIST) break;
    }
    return d0;
}
float GetLight(float3 p){
    float3 lightPos = float3(0,10,4) + float3(cos(_Time.y),0,sin(_Time.y));
    float3 l = normalize(lightPos - p);
    float3 n = GetNormal(p);
    float diff = saturate(dot(l,n));
    float d = Raymarch(p + n*SURF_DIST*2,l);
    if(d < distance(p,lightPos)) diff *= 0.1;
    return diff;
}


            fixed4 frag (v2f i) : SV_Target
            {
                float3 ro = float3(0,1,0);
                float3 rd = normalize(float3(i.worldPos.xy,1));
                float d = Raymarch(ro,rd);
                
                float3 p = ro + rd * d;
                float diff = GetLight(p);
                // return GetNormal(p).xyzx;
                return diff;
            }
            ENDCG
        }
    }
}
