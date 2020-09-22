// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/SimpleThinFilm"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _RampMap("RampMap",2d) = ""{}
        _NoiseMap("NoiseMap",2d) = ""{}
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
                float3 n:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _RampMap;
            sampler2D _NoiseMap;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.n = UnityObjectToWorldNormal(v.n);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 noise = tex2D(_NoiseMap,float2(i.uv));
                float3 n = normalize(i.n + noise);
                float3 l = _WorldSpaceLightPos0.xyz;
                float3 v = UnityWorldSpaceViewDir(i.worldPos);
                float3 h = normalize(l+v);

                float nl = saturate(dot(n,l));
                float nv = saturate(dot(n,v));
                float nh = dot(n,h);

                float4 ramp = tex2D(_RampMap,float2(nh*10,nl));

                // return ramp;

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col * nl*0.3 + ramp;
            }
            ENDCG
        }
    }
}
