// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Diffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rough("Rough",range(0,1)) = 0
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
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 n = normalize(i.n);

                // return lambert(n,l);
                return orenNayer(n,l,v,_Rough);
            }
            ENDCG
        }
    }
}
