// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Diffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rough("Rough",range(0,1)) = 0

        _Width("_Width",range(0.001,0.4)) = 0.1
    }

    CGINCLUDE
    float lambert(float3 n,float3 l){
        return max(dot(n,l),0);
    }
    float orenNayer(float3 n,float3 l,float3 v,float r){
        float r2 = r * r;
        float a = 1 - 0.5 * r2 /(r2 + 0.57);
        float b = 0.45 * r2 /(r2+0.09);
        float nl = dot(n,l);
        float nv = dot(n,v);
        float ga = dot(v - n*nv,n-n*nl);
        return max(0,nl) * (a + b * max(0,ga) * sqrt((1 - nv*nv) * (1 - nl*nl))/max(nl,nv));
    }


    
    // beckmann distribution
    float beckMann(float nh,float r){
        const float e = 2.718;
        float r2 = r * r;
        float nh2 = nh * nh;
        float a = (nh-1)/(r2 * nh2);
        float b = r2 * nh2 * nh2;
        return pow(e,a)/b;
    }

    float smithJoint(float nh,float nv,float nl,float vh){
        float invertVH = 1/vh;
        float g1 = 2*nh*nl*invertVH;
        float g2 = 2*nh * nv * invertVH;
        return min(1,min(g2,g1));
    }

    float fresnel(float f0,float vh){
        return f0 + (1-f0)* pow(vh,5);
    }

    float2 slide(float width,float progress,float2 uv){
        float halfWidth = width * 0.5;
        return saturate(abs((progress - uv)/halfWidth));
    }
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float3 n:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 n:TEXCOORD2;
                float3 worldPos:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Rough;
            float _Width;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.n = UnityObjectToWorldNormal(v.n);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 p = slide(_Width,_Rough,i.uv);
                return tex2D(_MainTex,p);

                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 n = normalize(i.n);
                float3 h = normalize(l+v);
                float nh = saturate(dot(n,h));
                float vh = saturate(dot(v,h));
                float nl = saturate(dot(n,l));
                float nv = saturate(dot(n,v));

                return smithJoint(nh,nv,nl,vh);
                return beckMann(nh,_Rough);
                // return lambert(n,l);
                return orenNayer(n,l,v,_Rough);
            }
            ENDCG
        }
    }
}
