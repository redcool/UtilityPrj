// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Raymarch1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Value("_Value",float) = 0

        _Color0("_Color0",color) = (1,0,0,0)
        _Color1("_Color1",color) = (0,1,0,0)
        _Color2("_Color2",color) = (0,0,1,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

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
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            float GetDist(float3 p){
                float4 sphere = float4(0,2,4,1);
                float spehreDist = distance(p,sphere.xyz) - sphere.w;
                float planeDist = p.y;
                return min(planeDist,spehreDist);
            }

            float Raymarch(float3 ro,float3 rd){
                float d0 = 0;
                for(int i=0;i<100;i++){
                    float3 p = ro + rd * d0;
                    d0 += GetDist(p);
                    if(d0 > 100 || d0 < 0.001) break;
                }
                return d0;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 ro = float3(0,1,0);
                float3 rd = float3(i.worldPos.xy,1);

                float4 c = Raymarch(ro,rd);
                return c/6;
            }
            ENDCG
        }
    }
}
